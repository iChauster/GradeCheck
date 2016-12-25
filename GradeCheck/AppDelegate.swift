//
//  AppDelegate.swift
//  GradeCheck
//
//  Created by Ivan Chau on 2/20/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    enum Shortcut : String {
        case grades = "CheckGrades"
        case assignments = "CheckAssignments"
        case statistics = "Statistics"
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if (!UserDefaults.standard.bool(forKey: "HasLaunchedOnce")){
            UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
            UserDefaults.standard.synchronize()
            let key = Keychain()
            key.setPasscode(identifier: "GCUsername", passcode: "");
            key.setPasscode(identifier: "GCPassword", passcode: "");
            key.setPasscode(identifier: "GCEmail", passcode:  "");
            UserDefaults.standard.set("Weighted", forKey: "GPA");
        }
            let types: UIUserNotificationType = [.alert, .badge, .sound]
            let settings = UIUserNotificationSettings(types: types, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            let oneSignal = OneSignal(launchOptions: launchOptions, appId: "83f615e3-1eab-4055-92ef-cb5f498968c9", handleNotification: nil)

        oneSignal?.idsAvailable({ (userId, pushToken) in
            print("UserId:%@", userId)
            if (pushToken != nil) {
                print("pushToken:%@", pushToken)
                UserDefaults.standard.set(userId, forKey: "userId");
                if(UserDefaults.standard.bool(forKey: "PushNotifs") == false){
                    UserDefaults.standard.set(true, forKey: "shouldUpdateUserToken");
                }
            }
        })
        OneSignal.defaultClient().enable(inAppAlertNotification: true)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("ayy");
        UserDefaults.standard.set(true, forKey: "PushNotifs");
        
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
        print("push notifs failed")
        UserDefaults.standard.set(false, forKey: "PushNotifs");
    }
    func application(_ application: UIApplication, performActionFor shortcutItem : UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void){
        
        //Handle quick Actions
        completionHandler(handleQuickAction(shortcutItem))
    }
    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        var quickActionHandled = false;
        let type = shortcutItem.type.components(separatedBy: ".").last!
        let loginView = self.window?.rootViewController as! LoginViewController
        if let shortcutType = Shortcut.init(rawValue: type) {
            switch shortcutType {
            case .grades :
                loginView.selectedIndex = 0;
                quickActionHandled = true
                break;
            case .assignments :
                loginView.selectedIndex = 1;
                quickActionHandled = true
                break;
            case .statistics :
                loginView.selectedIndex = 2;
                quickActionHandled = true
                break;
            }
        }
        return quickActionHandled
        
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

