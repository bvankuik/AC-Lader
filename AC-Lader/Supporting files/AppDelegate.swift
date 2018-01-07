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
        UserDefaults.standard.register(defaults: [constants.defaults.zoomKey: constants.defaults.zoomValue])
        constants.chargerTypes.forEach {
            let key = ChargerType.defaultsKey(sequence: $0.sequence)
            UserDefaults.standard.register(defaults: [key: $0.isHidden])
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
