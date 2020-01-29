//
//  AppDelegate.swift
//  LittleHelpers
//
//  Created by themisterholliday on 09/13/2019.
//  Copyright (c) 2019 themisterholliday. All rights reserved.
//

import UIKit
import LittleHelpers

class TheData: ChipCollectionViewControllerDataSource {
    var chipModels: [ChipModel] = [test()]
}

struct test: ChipModel {
    var title = "Testing@testingtesting.com"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var data = TheData()

    lazy var vc = ChipCollectionViewController.init(dataSource: data, delegate: self)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        _ = SimplePagerViewController(viewControllers: [RedViewController(), GreenViewController(), BlueViewController()])

        vc.collectionView.backgroundColor = .white
        vc.render(clearTextField: false)
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: ChipCollectionViewControllerDelegate {
    func chipViewTextFieldDidEndEditing() {

    }

    func chipViewTextFieldDidChange(text: String?) {

    }

    func chipViewTextFieldDidReturn(text: String?) {
        guard let text = text else { return }
        var item = test()
        item.title = text
        self.data.chipModels.append(item)
        vc.render(clearTextField: true)
    }

    func chipViewDidDelete(at indexPath: IndexPath) {
        self.data.chipModels.remove(at: indexPath.row)
        vc.render(clearTextField: false)
    }

    func chipViewTextFieldDidBeginEditing() {

    }
}


class RedViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
    }
}

class GreenViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
    }
}

class BlueViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
    }
}
