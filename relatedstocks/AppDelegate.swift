//
//  AppDelegate.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 16..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit
import UserNotifications
import GoogleMobileAds
import RestEssentials
import Firebase
import LSExtensions

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ReviewManagerDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var fullAd : GADInterstialManager?;
    var rewardAd : GADRewardManager?;
    var reviewManager : ReviewManager?;
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure();
        self.reviewManager = ReviewManager(self.window!, interval: 60.0 * 60 * 24 * 2); //*
        self.reviewManager?.delegate = self;
        self.reviewManager?.canShowFirstTime = false;
        
        self.rewardAd = GADRewardManager(self.window!, unitId: GADInterstitial.loadUnitId(name: "RewardAd") ?? "", interval: 60.0 * 60.0 * 24); //
        //self.rewardAd?.delegate = self;
        
        self.fullAd = GADInterstialManager(self.window!, unitId: GADInterstitial.loadUnitId(name: "FullAd") ?? "", interval: 60.0 * 60 * 1); //
        //self.fullAd?.delegate = self;
        //self.fullAd?.canShowFirstTime = false;
        //self.fullAd?.show();
        UNUserNotificationCenter.current().delegate = self;
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (result, error) in
            guard result else{
                return;
            }
            
            DispatchQueue.main.syncInMain {
                application.registerForRemoteNotifications();
            }
        }
        
        if let push = launchOptions?[.remoteNotification] as? [String: AnyObject]{
            let noti = push["aps"] as! [String: AnyObject];
            let alert = noti["alert"] as! [String: AnyObject];
            let title = alert["title"] as? String ?? "";
            let body = alert["body"] as? String ?? "";
            let category = alert["category"] as? String ?? "";
            let item = alert["item"] as? String ?? "";
            
            self.performPushCommand(title, body: body, category: category, item: item); 
            print("launching with push[\(push)]");
        }else if let launchUrl = launchOptions?[UIApplicationLaunchOptionsKey.url] as? URL{
            self.openKakaoUrl(launchUrl);
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard url.scheme == "kakaob6a4140bd033e58899a789ede456147f" else {
            return false;
        }
        
        self.openKakaoUrl(url);
        return true;
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("app going to foreground");
        guard ReviewManager.shared?.canShow ?? false else{
            //self.fullAd?.show();
            return;
        }
        ReviewManager.shared?.show();
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("app become active");
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var device = deviceToken.hexString;
            //.reduce("", {$0 + String(format: "%02X", $1)});
        print("APNs device[\(device)]");
        let restUrl = "http://222.122.212.176:3004/devices/insert";
        guard let rest = RestController.make(urlString: restUrl) else{
            return;
        }
        
        rest.post(["type":"ios","device":device]) { (result, res) in
            do{
                let data = try result.value();
                print("push reg. result[\(result)]");
            }catch let error{
                print("push reg error[\(error)]");
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error)");
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    func performPushCommand(_ title : String, body : String, category : String, item : String){
        var category = RSPushData.Category(rawValue: category);
        
        switch category{
        case .company?:
            RSTabbarController.startingIndex = 0;
            RSSearchTableViewController.startingKeyword = item;
            break;
        case .naver?:
            RSTabbarController.startingIndex = 0;
            RSTabbarController.startingUrl = item.naverUrlForSearch;
            break;
        case .story?:
            RSTabbarController.startingIndex = 2;
            RSTabbarController.startingUrl = URL(string: "http://andy3938.cafe24.com/gnu/bbs/board.php?bo_table=stock_story&wr_id=\(item)");
            break;
        default:
            RSTabbarController.startingIndex = 0;
            RSSearchTableViewController.startingKeyword = item.isEmpty ? body : item;
            break;
        }
    }
    
    func openKakaoUrl(_ url : URL){
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true);
        var queryCategory = urlComponents?.queryItems?.first(where: { (query) -> Bool in
            return query.name == "category";
        })
        var queryItem = urlComponents?.queryItems?.first(where: { (query) -> Bool in
            return query.name == "item";
        })
        var category = queryCategory?.value ?? "";
        var item = queryItem?.value ?? "";
        
        guard !item.isEmpty else{
            return;
        }
        
        print("open by kakao. catgory[\(category) item[\(item)]]");
        RSSearchTableViewController.startingKeyword = item;
    }
    
    // MARK: UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //update app
        print("receive push notification in foreground. identifier[\(notification.request.identifier)] title[\(notification.request.content.title)] body[\(notification.request.content.body)]");
        
        //UNNotificationPresentationOptions
        completionHandler([.alert, .sound]);
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("receive push. title[\(response.notification.request.content.title)] body[\(response.notification.request.content.body)] userInfo[\(response.notification.request.content.userInfo)]");
        let category = response.notification.request.content.userInfo["category"] as? String;
        let item = response.notification.request.content.userInfo["item"] as? String;
        self.performPushCommand(response.notification.request.content.title, body: response.notification.request.content.body, category: category ?? "", item: item ?? "");
        /*if let push = launchOptions?[.remoteNotification] as? [String: AnyObject]{
            let noti = push["aps"] as! [String: AnyObject];
            let alert = noti["alert"] as! [String: AnyObject];
            RSSearchTableViewController.startingKeyword = alert["body"] as? String ?? "";
            print("launching with push[\(push)]");
        }*/
        completionHandler();
    }
    
    // MARK: ReviewManagerDelegate
    func reviewGetLastShowTime() -> Date {
        return RSDefaults.LastShareShown;
    }
    
    func reviewUpdate(showTime: Date) {
        RSDefaults.LastShareShown = showTime;
    }
}

