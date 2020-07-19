//
//  ViewModelExample.swift
//  LittleHelpers
//
//  Created by Craig Holliday on 7/19/20.
//

import Foundation

class BookReviewModel {
    let rating = EventDispatcher(value: 5)
}

class BookReviewsViewModel {
    private let book: BookReviewModel
    private let bookReviewVC: BookReviewController

    init(book: BookReviewModel, bookReviewVC: BookReviewController) {
        self.book = book
        self.bookReviewVC = bookReviewVC
        bookReviewVC.delegate = self

        setupObservers()
    }

    func setupObservers() {
        book.rating.observe(self, distinct: true) { this, rating in
            this.bookReviewVC.label.text = String(rating)
        }
    }
}

extension BookReviewsViewModel: BookReviewControllerActions {
    func changeRating() {
        book.rating.value = 8
    }
}

protocol BookReviewControllerActions: class {
    func changeRating()
}

class BookReviewController: ViewControllerWithDelegate {
    weak var delegate: BookReviewControllerActions?
    let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate?.changeRating()
    }
}
