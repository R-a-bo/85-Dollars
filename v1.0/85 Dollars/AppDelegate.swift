//
//  AppDelegate.swift
//  85 Dollars
//
//  Created by George Birch on 5/31/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        print(CommandLine.arguments)
        if CommandLine.arguments.contains("--uitesting") {
            if let navController = window?.rootViewController as? UINavigationController {
                if let initialVC = navController.viewControllers[0] as? ScheduleListViewController {
                    initialVC.scheduleStorageService = MockScheduleStorageService()
                }
            }
        }
        
        return true
    }
    
    // MARK: UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner, .list, .sound])
    }


}

