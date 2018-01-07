//
//  AppDelegate.swift
//  AC-Lader
//
//  Created by Bart van Kuik on 06/01/2018.
//  Copyright © 2018 DutchVirtual. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let defaults = [
            constants.defaults.zoomKey: constants.defaults.zoomValue
        ]
        UserDefaults.standard.register(defaults: defaults)
        constants.chargerTypes.forEach {
            let key = String(format: "%@%d", constants.defaults.chargerTypeHiddenKey, $0.sequence)
            let value = $0.isHidden
            UserDefaults.standard.register(defaults: [key: value])
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}
