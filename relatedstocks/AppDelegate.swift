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
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ReviewManagerDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var fullAd : GADInterstialManager?;
    var rewardAd : GADRewardManager?;
    var reviewManager : ReviewManager?;
    var deviceToken : String?;
    
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
        
        /**
         Nodejs:
             {
                 title: ..
                 body: ..
                 sound: "default",
                 topic: "com.y2k..."
                 payload: {
                     category: category,
                     item: item
                 }
             }
        */
        if let push = launchOptions?[.remoteNotification] as? [String: AnyObject]{
            let noti = push["aps"] as! [String: AnyObject];
            let alert = noti["alert"] as! [String: AnyObject];
            let title = alert["title"] as? String ?? "";
            let body = alert["body"] as? String ?? "";
            //Custom data can be receive from 'aps' not 'alert'
            let category = push["category"] as? String ?? "";
            let item = push["item"] as? String ?? "";
            
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
        self.deviceToken = deviceToken.hexString;
            //.reduce("", {$0 + String(format: "%02X", $1)});
        print("APNs device[\(self.deviceToken ?? "")] => \(RSStockController.PushRegURL.absoluteString)");
        
        let params = ["type":"ios","device":self.deviceToken ?? ""];
        Alamofire.request(RSStockController.PushRegURL, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { (res) in
                guard res.error == nil else{
                    print("push reg. error[\(res.error.debugDescription)]");
                    return;
                }
                
                print("push reg. result[\(res.response?.description ?? "")]");
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error)");
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    func performPushCommand(_ title : String, body : String, category : String, item : String){
        let category = RSPushData.Category(rawValue: category);
        print("parse push command. category[\(category)] item[\(item)] title[\(title)] body[\(body)]");
        
        switch category{
        case .company?:
            RSTabbarController.startingIndex = 0;
            RSSearchTableViewController.startingKeyword = item;
            break;
        case .naver?:
            print("push command. open naver. item[\(item)]");
            RSTabbarController.startingIndex = 0;
            RSTabbarController.startingUrl = item.naverUrlForSearch;
            break;
        case .story?:
            RSTabbarController.startingIndex = 2;
            RSTabbarController.startingUrl = URL(string: "http://andy3938.cafe24.com/gnu/bbs/board.php?bo_table=stock_story&wr_id=\(item)");
            break;
        default:
            print("receive unkown command. category[\(category.debugDescription)]");
            RSTabbarController.startingIndex = 0;
            RSSearchTableViewController.startingKeyword = item.isEmpty ? body : item;
            break;
        }
    }
    
    func openKakaoUrl(_ url : URL){
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true);
        var params : [String : String] = urlComponents?.queryItems?
            .reduce(into: [String : String]()){ $0[$1.name] = $1.value ?? "" } ?? [:]
        let category = params["category"] ?? "";
        let item = params["item"] ?? "";
        let keyword = params["keyword"] ?? "";
        
        guard !item.isEmpty else{
            return;
        }
        
        print("open by kakao. catgory[\(category) item[\(item)]]");
        RSTabbarController.startingIndex = 0;
        RSTabbarController.openNaver(withItem: item, withKeyword: keyword);
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

