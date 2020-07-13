//
//  ChipsCollectionViewController.swift
//  LittleHelpers
//
//  Created by Craig Holliday on 12/5/19.
//

import Foundation

protocol ChipTextFieldCollectionViewCellDelegate: class {
    func textFieldDidChange(text: String?)
    func textFieldDidReturn(text: String?)
    func textFieldBeginEditing(textField: UITextField)
    func textFieldEndEditing(textField: UITextField)
}

final class ChipTextFieldCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    static let ReuseIdentifier = "ChipTextFieldCollectionViewCell"

    var textField: UITextField = UITextField()
    weak var delegate: ChipTextFieldCollectionViewCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textField)

        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textField.text = nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.textFieldDidReturn(text: textField.text)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldBeginEditing(textField: textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldEndEditing(textField: textField)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.textFieldDidChange(text: textField.text)
    }
}

protocol ChipCollectionViewCellDelegate: class {
    func didTapDeleteButton(for indexPath: IndexPath)
}

final class ChipCollectionViewCell: UICollectionViewCell {
    static let ReuseIdentifier = "ChipCollectionViewCell"

    weak var delegate: ChipCollectionViewCellDelegate?

    var indexPath: IndexPath?
    var titleLabel = UILabel()
    var cancelImageView = UIImageView()
    var deleteButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(cancelImageView)
        addSubview(deleteButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        cancelImageView.translatesAutoresizingMaskIntoConstraints = false

        let leading = titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        leading.constant = 8
        NSLayoutConstraint.activate([
            leading,
            titleLabel.trailingAnchor.constraint(equalTo: cancelImageView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            deleteButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            deleteButton.topAnchor.constraint(equalTo: topAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            cancelImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
            cancelImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cancelImageView.topAnchor.constraint(equalTo: topAnchor),
            cancelImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        deleteButton.tap = { [weak self] in
            guard let `self` = self, let indexPath = self.indexPath else { return }
            self.delegate?.didTapDeleteButton(for: indexPath)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    func configure(title: String, indexPath: IndexPath) {
        titleLabel.text = title
        self.indexPath = indexPath
    }
}

public protocol ChipModel {
    var title: String { get }
}

public protocol ChipCollectionViewControllerDataSource {
    var chipModels: [ChipModel] { get }
}

public protocol ChipCollectionViewControllerDelegate: class {
    func chipViewTextFieldDidBeginEditing()
    func chipViewTextFieldDidEndEditing()
    func chipViewTextFieldDidChange(text: String?)
    func chipViewTextFieldDidReturn(text: String?)
    func chipViewDidDelete(at indexPath: IndexPath)
}

public final class ChipCollectionViewController: UICollectionViewController {
    private let dataSource: ChipCollectionViewControllerDataSource
    private weak var delegate: ChipCollectionViewControllerDelegate?

    private var previousData: [ChipModel] = []

    private var textFieldCell: ChipTextFieldCollectionViewCell?

    public init(dataSource: ChipCollectionViewControllerDataSource, delegate: ChipCollectionViewControllerDelegate) {
        self.dataSource = dataSource
        super.init(collectionViewLayout: UICollectionViewLayout())
        self.delegate = delegate

        collectionView.register(ChipTextFieldCollectionViewCell.self, forCellWithReuseIdentifier: ChipTextFieldCollectionViewCell.ReuseIdentifier)
        collectionView.register(ChipCollectionViewCell.self, forCellWithReuseIdentifier: ChipCollectionViewCell.ReuseIdentifier)

        let layout = ChipsFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.collectionViewLayout.invalidateLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func render(clearTextField: Bool) {
        if clearTextField {
            textFieldCell?.textField.text = nil
        }

        let diff = diffChanges(previousData, dataSource.chipModels, with: { (lhs, rhs) -> Bool in
            lhs.title == rhs.title
        }, updatesCompare: { _, _ in false })

        let insertedIndexPaths = diff.insertedIndexPaths ?? []
        let deletedIndexPaths = diff.deletedIndexPaths ?? []

        collectionView.performBatchUpdates({
            collectionView.insertItems(at: insertedIndexPaths)
            collectionView.deleteItems(at: deletedIndexPaths)
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let lastIndexPath = IndexPath(item: self.dataSource.chipModels.count, section: 0)
                self.collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
            }
        }

        previousData = dataSource.chipModels
    }
}

extension ChipCollectionViewController {
    public override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.chipModels.count + 1
    }

    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard dataSource.chipModels.count != indexPath.row else {
            if let textFieldCell = textFieldCell {
                return textFieldCell
            }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChipTextFieldCollectionViewCell.ReuseIdentifier, for: indexPath) as? ChipTextFieldCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.delegate = self
            cell.textField.placeholder = "Type here"
            textFieldCell = cell
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChipCollectionViewCell.ReuseIdentifier, for: indexPath) as? ChipCollectionViewCell else {
            return UICollectionViewCell()
        }

        if let item = dataSource.chipModels[safe: indexPath.row] {
            cell.configure(title: item.title, indexPath: indexPath)
            cell.delegate = self
            cell.backgroundColor = .red
            cell.titleLabel.font = UIFont.systemFont(ofSize: 14)
        }

        return cell
    }
}

extension ChipCollectionViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Create label used for retrieving text size
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)

        // If last cell return default size
        guard dataSource.chipModels.count != indexPath.row else {
            return CGSize(width: 200, height: 32)
        }

        guard let viewModel = dataSource.chipModels[safe: indexPath.row] else {
            return CGSize(width: 200, height: 32)
        }

        label.text = viewModel.title

        // Add 32 spacing to account for spacing between label as well as cancel button to get final width
        let labelWidth = label.intrinsicContentSize.width + 32 + 12
        return CGSize(width: labelWidth, height: 32)
    }
}

extension ChipCollectionViewController: ChipTextFieldCollectionViewCellDelegate {
    func textFieldDidChange(text: String?) {
        delegate?.chipViewTextFieldDidChange(text: text)
    }

    func textFieldDidReturn(text: String?) {
        delegate?.chipViewTextFieldDidReturn(text: text)
    }

    func textFieldBeginEditing(textField: UITextField) {
        delegate?.chipViewTextFieldDidBeginEditing()
    }

    func textFieldEndEditing(textField: UITextField) {
        delegate?.chipViewTextFieldDidEndEditing()
    }
}

extension ChipCollectionViewController: ChipCollectionViewCellDelegate {
    func didTapDeleteButton(for indexPath: IndexPath) {
        delegate?.chipViewDidDelete(at: indexPath)
    }
}

final class ChipsFlowLayout: UICollectionViewFlowLayout {
    private let MinimalEditFieldWidth = 100.0

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left // initalized to silence compiler, and actaully safer, but not planning to use.
        var maxY: CGFloat = -1.0

        // this loop assumes attributes are in IndexPath order
        for attribute in attributes ?? [] {
            if attribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            var width = attribute.frame.size.width
            if attribute == attributes?.last {
                let newWidth = rect.size.width - leftMargin - minimumInteritemSpacing
                if newWidth >= CGFloat(MinimalEditFieldWidth) {
                    width = newWidth
                } else {
                    width = rect.size.width
                }
            }

            attribute.frame = CGRect(x: leftMargin, y: attribute.frame.origin.y, width: width, height: attribute.frame.size.height)

            leftMargin += attribute.frame.size.width + minimumInteritemSpacing
            maxY = max(attribute.frame.maxY, maxY)
        }

        return attributes
    }
}

// MARK: - Helpers

private extension Collection {
    /// SwifterSwift: Safe protects the array from out of bounds by use of optional.
    ///
    ///        let arr = [1, 2, 3, 4, 5]
    ///        arr[safe: 1] -> 2
    ///        arr[safe: 10] -> nil
    ///
    /// - Parameter index: index of element to access element.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

final class CollectionViewDataSource<Model>: NSObject, UICollectionViewDataSource {
    typealias CellConfigurator = (Model, UICollectionViewCell, IndexPath) -> Void

    var models: [Model]

    private let reuseIdentifier: String
    private let cellConfigurator: CellConfigurator

    init(models: [Model],
         reuseIdentifier: String,
         cellConfigurator: @escaping CellConfigurator) {
        self.models = models
        self.reuseIdentifier = reuseIdentifier
        self.cellConfigurator = cellConfigurator
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        )

        if let model = modelForItem(at: indexPath) {
            cellConfigurator(model, cell, indexPath)
        }

        return cell
    }

    func modelForItem(at indexPath: IndexPath) -> Model? {
        return models[safe: indexPath.row]
    }
}

extension CollectionViewDataSource where Model == ChipModel {
    static func make(for models: [ChipModel],
                     reuseIdentifier: String = ChipCollectionViewCell.ReuseIdentifier) -> CollectionViewDataSource {
        return CollectionViewDataSource(
            models: models,
            reuseIdentifier: reuseIdentifier
        ) { model, cell, indexPath in
            (cell as? ChipCollectionViewCell)?.configure(title: model.title, indexPath: indexPath)
        }
    }
}

public func diffChanges<T>(_ first: [T],
                           _ second: [T],
                           with compare: (T, T) -> Bool,
                           updatesCompare: (T, T) -> Bool) -> DiffChanges<T> {
    let combinations = first.enumerated().compactMap { index, firstElement in
        ((index, firstElement), second.enumerated().first { secondElementIndex, secondElement in
            compare(firstElement, secondElement) && index == secondElementIndex
        })
    }

    let common = combinations.filter { $0.1 != nil }.compactMap { ($0.0, $0.1!) }

    let deletedCombinations = combinations.filter { $0.1 == nil }
    let deleted = deletedCombinations.compactMap { ($0.0) }

    let inserted = second.enumerated().filter { secondElement in
        !common.contains { compare($0.0.1, secondElement.element) }
    }

    let updated = inserted.filter { secondElement in
        deletedCombinations.contains { updatesCompare($0.0.1, secondElement.element) }
    }

    let finalDeleted = deleted.filter { element in !updated.contains { updatesCompare(element.1, $0.element) } }
    let finalInserted = inserted.filter { element in !updated.contains { updatesCompare(element.element, $0.element) } }

    let insertedDiffItems = finalInserted.map { DiffItem(item: $0.element, index: $0.offset) }
    let deletedDiffItems = finalDeleted.map { DiffItem(item: $0.1, index: $0.0) }
    let updatedDiffItems = updated.map { DiffItem(item: $0.element, index: $0.offset) }

    return DiffChanges(inserted: insertedDiffItems, deleted: deletedDiffItems, updated: updatedDiffItems)
}

public struct DiffItem<T> {
    public let item: T
    public let index: Int
}

public struct DiffChanges<T> {
    public let inserted: [DiffItem<T>]
    public let deleted: [DiffItem<T>]
    public let updated: [DiffItem<T>]

    var insertedIndexPaths: [IndexPath]? {
        guard !inserted.isEmpty else {
            return nil
        }
        return inserted.map { IndexPath(row: $0.index, section: 0) }
    }

    var deletedIndexPaths: [IndexPath]? {
        guard !deleted.isEmpty else {
            return nil
        }
        return deleted.map { IndexPath(row: $0.index, section: 0) }
    }

    var updatedIndexPaths: [IndexPath]? {
        guard !updated.isEmpty else {
            return nil
        }

        return updated.compactMap {
            let index = $0.index
            guard !inserted.map({ $0.index }).contains(index),
                !deleted.map({ $0.index }).contains(index) else {
                return nil
            }
            return IndexPath(row: index, section: 0)
        }
    }
}
