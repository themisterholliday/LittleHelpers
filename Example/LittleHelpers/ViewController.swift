//
//  ViewController.swift
//  LittleHelpers
//
//  Created by themisterholliday on 09/13/2019.
//  Copyright (c) 2019 themisterholliday. All rights reserved.
//

import UIKit
import LittleHelpers

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class ListNavigator: UIViewController, Navigator {
    enum Destination {
        case bookDetail(bookId: String, bookManager: BookManager)
    }

    private let viewControllerFactory: ListViewControllerFactoryProtocol

    init(bookManager: BookManager, viewControllerFactory: ListViewControllerFactoryProtocol) {
        self.viewControllerFactory = viewControllerFactory

        super.init(nibName: nil, bundle: nil)

        self.addChildViewController(viewControllerFactory.makeBookList(with: bookManager, navigator: self))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func navigate(to destination: Destination) {
        let viewController = makeViewController(for: destination)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func makeViewController(for destination: Destination) -> UIViewController {
        switch destination {
        case .bookDetail(let bookId, let bookManager):
            return viewControllerFactory.makeBookDetail(for: bookId, bookManager: bookManager)
        }
    }
}

protocol ListViewControllerFactoryProtocol {
    func makeBookList(with bookManager: BookManager, navigator: ListNavigator) -> UIViewController
    func makeBookDetail(for bookId: String, bookManager: BookManager) -> UIViewController
}

//class ListViewControllerFactory: ListViewControllerFactoryProtocol {
//    func makeBookList(with bookManager: BookManager, navigator: ListNavigator) -> UIViewController {
//        let viewModel = BookListViewModel(dataManager: bookManager, navigator: navigator)
//        let viewController = BookListViewController(viewModel: viewModel)
//        viewModel.configure(view: viewController)
//        return viewController
//    }
//
//    func makeBookDetail(for bookId: String, bookManager: BookManager) -> UIViewController {
//        let viewModel = ExampleBookViewModel(bookId: bookId, dataManager: bookManager)
//        let viewController = BookDetailViewController(viewModel: viewModel)
//        viewModel.configure(view: viewController)
//        return viewController
//    }
//}

class BookDatabase {
    private var books = List<Book>()
    private var nodes = [String : List<Book>.Node]()

    init() {
        let books = [
            Book(id: "0", name: "BOOK 1", author: (name: "AUTHOR", test: "test"), isAvailable: false, price: 1),
            Book(id: "1", name: "BOOK 2", author: (name: "AUTHOR", test: "test"), isAvailable: false, price: 1),
            Book(id: "2", name: "BOOK 3", author: (name: "AUTHOR", test: "test"), isAvailable: false, price: 1),
            Book(id: "3", name: "BOOK 4", author: (name: "AUTHOR", test: "test"), isAvailable: false, price: 1)
        ]
        books.forEach { (book) in
            nodes[book.id] = self.books.append(book)
        }
    }

    func add(_ book: Book) {
        nodes[book.id] = books.append(book)
    }

    func remove(_ book: Book) {
        guard let node = nodes.removeValue(forKey: book.id) else {
            return
        }

        books.remove(node)
    }

    func getAllBooks() -> [Book] {
        return books.compactMap({ $0 })
    }

    func getBook(for id: String) -> Book? {
        return nodes[id]?.value
    }

    func updateBook(with book: Book) {
        nodes[book.id]?.value = book
    }
}

class BookManager {
    private var database: BookDatabase

    internal var observations = (
        all: [UUID: ([Book]) -> Void](),
        single: [UUID: (String, (Book) -> Void)]()
    )

    init(database: BookDatabase) {
        self.database = database
    }

    func getBook(for id: String) -> Book? {
        return database.getBook(for: id)
    }

    func update(with book: Book) {
        database.updateBook(with: book)

        handleNotifySingleObservations(for: book.id)
    }
}

extension BookManager: ObservableManager {
    typealias Object = Book

    internal func getObject(for id: String) -> Book? {
        return database.getBook(for: id)
    }

    internal func getAllObjects() -> [Book] {
        return database.getAllBooks()
    }

    internal func handleNotifySingleObservations(for id: String) {
        observations.single.values.forEach { (key, closure) in
            guard key == id, let updatedObject = getObject(for: id) else {
                return
            }
            closure(updatedObject)
        }

        observations.all.values.forEach { (closure) in
            closure(self.getAllObjects())
        }
    }
}

extension Book: MangersObservableObject {}

struct Book {
    let id: String
    var name: String
    let author: (name: String, test: String)
    var isAvailable: Bool
    var price: Int
}
