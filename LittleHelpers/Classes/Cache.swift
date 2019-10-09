//
//  Cache.swift
//  LittleHelpers
//
//  Created by Craig Holliday on 10/1/19.
//

import Foundation

// https://www.swiftbysundell.com/articles/caching-in-swift/

/// A class to cache any Codable type with entry lifetime as well as max entry count.
public final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval
    private let keyTracker = KeyTracker()

    /// Init
    /// - Parameter dateProvider: Date provider to create starting point to check against `entryLifetime`. Defaults to Date() and is a function for testing purposes.
    /// - Parameter entryLifetime: The maximum time interval the entry will stay in the cache. Defaults to 12 hours.
    /// - Parameter maximumEntryCount: The maximum entries this cache can hold. Defaults to 50.
    public init(dateProvider: @escaping () -> Date = Date.init, entryLifetime: TimeInterval = 12 * 60 * 60, maximumEntryCount: Int = 50) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
    }

    public func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
    }

    public func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        guard dateProvider() < entry.expirationDate else {
            // Discard values that have expired
            removeValue(forKey: key)
            return nil
        }

        return entry.value
    }

    public func allValues() -> [Value] {
        let allKeys = keyTracker.keys
        return allKeys.compactMap({ self.value(forKey: $0) })
    }

    public func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }

    public func removeAllValues() {
        let allKeys = keyTracker.keys
        allKeys.forEach({ self.removeValue(forKey: $0) })
    }
}

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

private extension Cache {
    final class Entry {
        let key: Key
        let value: Value
        let expirationDate: Date

        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}

public extension Cache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}

// MARK: - Cache Persistence

private extension Cache {
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()

        func cache(_ cache: NSCache<AnyObject, AnyObject>,
                   willEvictObject object: Any) {
            guard let entry = object as? Entry else {
                return
            }

            keys.remove(entry.key)
        }
    }
}

extension Cache.Entry: Codable where Key: Codable, Value: Codable {}

private extension Cache {
    func entry(forKey key: Key) -> Entry? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }

        return entry
    }

    func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
    }
}

extension Cache: Codable where Key: Codable, Value: Codable {
    public convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap(entry))
    }
}

extension Cache where Key: Codable, Value: Codable {
    public func saveToDisk(withName name: String, using fileManager: FileManager = .default) throws {
        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        let data = try JSONEncoder().encode(self)
        try data.write(to: fileURL)
    }

    public static func loadFromDisk(name: String, using fileManager: FileManager = .default) throws -> Cache {
        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        guard let data = fileManager.contents(atPath: fileURL.path) else {
            throw CacheError.noDataAtFilePath(filePath: fileURL.path)
        }
        let cache = try JSONDecoder().decode(Cache.self, from: data)
        return cache
    }
}

enum CacheError: Error {
    case noDataAtFilePath(filePath: String)
}

extension CacheError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noDataAtFilePath(let filePath):
            return NSLocalizedString(
                "Coulde not find data at file path: \(filePath)",
                comment: ""
            )
        }
    }
}


// MARK: - Example
struct Article: Identifiable, Codable {
    let id: Identifier<Article>
    let name: String
}

private class ArticleDatabase: Database {
    typealias T = Article

    func record(withID id: Identifier<Article>) -> Article? {
        return nil
    }
}

private class ArticleLoader: ModelLoader {
    typealias T = Article

    private let cacheFileName = "articles"

    lazy var cache: Cache<Article.RawIdentifier, Article> = {
        return (try? Cache<Article.RawIdentifier, Article>.loadFromDisk(name: cacheFileName)) ?? Cache<Article.RawIdentifier, Article>()
    }()

    func loadModel(withID id: Identifier<Article>) throws -> Article {
        guard let cached = cache[id.rawValue] else {
            throw IdentifiableModelError<T>.couldNotFindModelWithID(id: id)
        }
        return cached
    }

    func saveModel(withID id: Identifier<Article>) throws {
        let article = Article(id: id, name: "article 1")
        cache.insert(article, forKey: article.id.rawValue)
        try cache.saveToDisk(withName: cacheFileName)
    }
}
