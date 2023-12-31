//
//  AppDelegate.swift
//  寶島旅社
//
//  Created by Eric Lin on 2022/10/12.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // NavigationBarStyle設定
        UINavigationBar.appearance().tintColor = UIColor.orangeRed
        if #available(iOS 15.0, *) {
            let barAppearance =  UINavigationBarAppearance()
            barAppearance.backgroundColor = UIColor.sageGreen
            barAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.orangeRed,
                                                 NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
            UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
            UINavigationBar.appearance().standardAppearance = barAppearance
        } else {
            UINavigationBar.appearance().barTintColor = UIColor.sageGreen
            UINavigationBar.appearance().backgroundColor = UIColor.sageGreen
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.orangeRed,
                                                                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

