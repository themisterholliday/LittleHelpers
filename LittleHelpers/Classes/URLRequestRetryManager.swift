//
//  URLRequestRetryManager.swift
//  LittleHelpers
//
//  Created by Craig Holliday on 10/9/19.
//

import Foundation

enum CacheableURLRequestError: Error {
    case noURLOnURLRequest
}

// @TODO: better handling for errors
struct CacheableURLRequest: Codable {
    let id: UUID
    let url: URL
    let headers: [String: String]?
    let body: Data?
    let currentRetryCount: Int

    init(request: URLRequest, currentRetryCount: Int) throws {
        guard let requestURL = request.url else {
            throw CacheableURLRequestError.noURLOnURLRequest
        }
        url = requestURL
        headers = request.allHTTPHeaderFields
        body = request.httpBody
        id = UUID()
        self.currentRetryCount = currentRetryCount
    }

    func asURLRequest() -> URLRequest {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}

private class URLRequestCache {
    private let cacheFileName = "cachedRequests"

    private lazy var cache: Cache<UUID, CacheableURLRequest> = {
        (try? Cache<UUID, CacheableURLRequest>.loadFromDisk(name: cacheFileName)) ?? Cache<UUID, CacheableURLRequest>()
    }()

    func loadAllRequests() -> [CacheableURLRequest] {
        return cache.allValues()
    }

    func loadRequest(forID id: UUID) -> CacheableURLRequest? {
        return cache.value(forKey: id)
    }

    func removeRequest(id: UUID) throws {
        cache.removeValue(forKey: id)
        try cache.saveToDisk(withName: cacheFileName)
    }

    func save(request: CacheableURLRequest) throws {
        cache.insert(request, forKey: request.id)
        try cache.saveToDisk(withName: cacheFileName)
    }
}

// MARK: - URLRequestRetryManager

public final class URLRequestRetryManager: NSObject {
    private static let ApolloOperationName = "X-APOLLO-OPERATION-NAME"
    private static let OperationsToAlwaysRetry = ["UserProgress", "AddFavorite", "RemoveFavorite"]

    private lazy var session: URLSession = URLSession(configuration: .default)
    private lazy var cache = URLRequestCache()
}

extension URLRequestRetryManager {
    /// Cache a request to be retried when network connection is available
    public func cacheRequest(_ request: URLRequest) {
        do {
            let cacheableRequest = try CacheableURLRequest(request: request, currentRetryCount: 0)
            try cache.save(request: cacheableRequest)
        } catch {
            print(error)
        }
    }

    /// Loops through and starts all data tasks in `cache`
    public func startRetryingRequests() {
        // @AUDIT: Currently there is no limit to the amount of requests that can be made. Should most likely implement an operation queue.
        // @AUDIT: There is also no max retry count but there is a maximum lifetime for the entry in the cache which is defaulted to 12 hours
        let loadedRequests = cache.loadAllRequests()
        loadedRequests.forEach { cachedRequest in
            let urlRequest = cachedRequest.asURLRequest()
            let dataTask = session.dataTask(with: urlRequest) { [weak self] _, _, error in
                if let error = error {
                    print(error)
                    return
                }
                self?.handleDataTaskCompletion(cachedRequestId: cachedRequest.id)
            }
            dataTask.resume()
        }
    }

    private func handleDataTaskCompletion(cachedRequestId: UUID) {
        do {
            try cache.removeRequest(id: cachedRequestId)
        } catch {
            print(error)
        }
    }
}
