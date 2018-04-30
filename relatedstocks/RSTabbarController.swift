//
//  RSTabbarController.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 16..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit

/**
    Root UITabBarController
 */
class RSTabbarController: UITabBarController {
    private(set) static var shared : RSTabbarController!;
    
    /**
        Setter for Index of Tab to open by Kakao-Link or Push Notification
     */
    static var startingIndex : Int = 0{
        didSet{
            RSTabbarController.shared?.selectedIndex = startingIndex;
        }
    }
    
    /**
         Setter for Url to open by Kakao-Link or Push Notification
     */
    static var startingUrl : URL!{
        didSet{
            RSTabbarController.shared?.loadUrl(startingUrl);
        }
    }
    
    var oldIndex : Int = 0;
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Store instance to process Kakao-Link or Push Notification
        RSTabbarController.shared = self;
        
        //resizing image of tab items
        var items = self.tabBar.items ?? [];
        var iconSize = CGSize(width: 30.0, height: 30.0);
        items[0].image = UIImage(named: "search.png")?.image(withSize: iconSize);
        items[1].image = UIImage(named: "list.png")?.image(withSize: iconSize);
        items[2].image = UIImage(named: "story.png")?.image(withSize: iconSize);
        items[3].image = UIImage(named: "zoom.png")?.image(withSize: iconSize);
        items[4].image = UIImage(named: "notification.png")?.image(withSize: iconSize);
        
        // Do any additional setup after loading the view.
        //Apply starting tab and staring url from Kakao-Link or Push Notification
        //To fix bug of searchBar : When view controller appears first time, searchBar does not show keyboard.
        self.selectedIndex = 1;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.selectedIndex = RSTabbarController.startingIndex;
        
        if RSTabbarController.startingUrl != nil{
            self.loadUrl(RSTabbarController.startingUrl);
        }
    }
    
    func loadUrl(_ url : URL){
        // MARK: Open web url with webView
        if let internetView = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "RSInternetViewController") as? RSInternetViewController{
            internetView.startingUrl = url.absoluteString;
            (RSTabbarController.shared.selectedViewController as? UINavigationController)?.pushViewController(internetView, animated: true);
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.index(of: item) else{
            return;
        }
        
        print("tap tab bar. name[\(item.title?.description ?? "")] index[\(self.selectedIndex.description)] old[\(self.oldIndex.description)]");
        //reset search view
        if index == 0 && self.oldIndex == index{
            let nav = self.selectedViewController as? UINavigationController;
            nav?.popToRootViewController(animated: true);
            let searchView = nav?.topViewController as? RSSearchTableViewController;
            print("clear search view");
            searchView?.clear();
        }
        
        self.oldIndex = index;
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
//        if let internetView = segue.destination as? RSInternetViewController{
//            var cell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as? RSSearchCell;
//            var company = cell?.titleLabel?.text;
//            internetView.company = "특징주";
        
//            print("segue name[\(segue.identifier)]");
//        }
    }
}
