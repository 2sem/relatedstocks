//
//  RSTabbarController.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 16..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit

class RSTabbarController: UITabBarController {
    private(set) static var shared : RSTabbarController!;
    
    static var startingIndex : Int = 0{
        didSet{
            RSTabbarController.shared?.selectedIndex = startingIndex;
        }
    }
    static var startingUrl : URL!{
        didSet{
            RSTabbarController.shared?.loadUrl(startingUrl);
        }
    }
    
    var oldIndex : Int = 0;
    
    override func viewWillAppear(_ animated: Bool) {
        if let nav = self.viewControllers?[0] as? UINavigationController{
//            nav.hidesBottomBarWhenPushed = false;
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        RSTabbarController.shared = self;
        
        var items = self.tabBar.items ?? [];
        var iconSize = CGSize(width: 30.0, height: 30.0);
        items[0].image = UIImage(named: "search.png")?.image(withSize: iconSize);
        items[1].image = UIImage(named: "list.png")?.image(withSize: iconSize);
        items[2].image = UIImage(named: "story.png")?.image(withSize: iconSize);
        items[3].image = UIImage(named: "zoom.png")?.image(withSize: iconSize);
        
        if let nav = self.viewControllers?[2] as? UINavigationController{
            if let view = nav.visibleViewController as? RSInternetViewController{
//                view.url = NSURL(string:"http://221.149.97.129:8282/gnu/bbs/board.php?bo_table=stock_story") as URL!;
//                view.hidesBottomBarWhenPushed = false;
//                view.title = "주식이야기";
//                view.tabBarItem.title = view.title;
            }
            
        }

        //self.navigationController?.tabBarItem.image = UIImage(named: "list.png")?.image(withSize: CGSize(width: 44.0, height: 44.0));
//        items[0].title = "관련주식검색";
//        items[1].title = "나의관심주";
//        UITabBarItem(tabBarSystemItem: <#T##UITabBarSystemItem#>, tag: <#T##Int#>)
        // Do any additional setup after loading the view.
        self.selectedIndex = RSTabbarController.startingIndex;
        if RSTabbarController.startingUrl != nil{
            self.loadUrl(RSTabbarController.startingUrl);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUrl(_ url : URL){
        if let internetView = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "RSInternetViewController") as? RSInternetViewController{
            internetView.startingUrl = url.absoluteString;
            (RSTabbarController.shared.selectedViewController as? UINavigationController)?.pushViewController(internetView, animated: true);
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.index(of: item) else{
            return;
        }
        
        print("tap tab bar. name[\(item.title)] index[\(self.selectedIndex)] old[\(self.oldIndex)]");
        //reset search view
        if index == 0 && self.oldIndex == index{
            var nav = self.selectedViewController as? UINavigationController;
            nav?.popToRootViewController(animated: true);
            var searchView = nav?.topViewController as? RSSearchTableViewController;
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
