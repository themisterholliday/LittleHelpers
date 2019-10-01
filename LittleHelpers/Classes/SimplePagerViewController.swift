//
//  SimplePagerViewController.swift
//  LittleHelpers
//
//  Created by Craig Holliday on 9/27/19.
//

import UIKit

protocol SimplePagerViewControllerDelegate: class {
    func simplePagerViewControllerDidUpdatePageIndex(to index: Int)
}

public class SimplePagerViewController: UIViewController {
    weak var delegate: SimplePagerViewControllerDelegate?

    private var viewControllers: [UIViewController]
    private lazy var pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private lazy var pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: 150, height: 150))

    public init(viewControllers: [UIViewController], showPageControl: Bool = true) {
        self.viewControllers = viewControllers

        super.init(nibName: nil, bundle: nil)

        pageController.dataSource = self
        pageController.delegate = self

        if let firstViewController = viewControllers.first {
            pageController.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }

        addChildViewController(pageController)

        if showPageControl {
            addPageControl()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addPageControl() {
        pageControl.numberOfPages = viewControllers.count
        self.view.addSubview(pageControl)

        pageControl.translatesAutoresizingMaskIntoConstraints = false

        var bottomConstraint: NSLayoutConstraint = pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        if #available(iOS 11.0, *) {
            bottomConstraint = pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        }
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomConstraint
        ])
    }
}

extension SimplePagerViewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return viewControllers.last
        }

        guard viewControllers.count > previousIndex else {
            return nil
        }
        return viewControllers[previousIndex]
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = viewControllers.count

        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return viewControllers.first
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return viewControllers[nextIndex]
    }
}

extension SimplePagerViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let newViewController = pageController.viewControllers?.first, let updatedIndex = viewControllers.firstIndex(of: newViewController) else {
            return
        }
        delegate?.simplePagerViewControllerDidUpdatePageIndex(to: updatedIndex)
        pageControl.currentPage = updatedIndex
    }
}
