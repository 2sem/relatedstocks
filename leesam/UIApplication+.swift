//
//  UIApplication.swift
//  relatedstocks
//
//  Created by 영준 이 on 2017. 1. 10..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication{
    var appId : String{
        get{
            return "1189758512";
        }
    }
    
    var displayName : String?{
        get{
            var value = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String;
            if value == nil{
                value = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String;
            }
            
            return value;
        }
    }
    
    var urlForItunes : URL{
        get{
            return URL(string :"https://itunes.apple.com/kr/app/gwanlyeonjusiggeomsaeggi/id\(self.appId)?l=ko&mt=8")!;
        }
    }
    
    func openItunes(){
        self.open(self.urlForItunes, options: [:], completionHandler: nil) ;
    }
    
    func openReview(_ appId : String = "1189758512", completion: ((Bool) -> Void)? = nil){
        var rateUrl = URL(string: "https://itunes.apple.com/app/myapp/id\(appId)?mt=8&action=write-review");
        
        self.open(rateUrl!, options: [:], completionHandler: completion);
    }
}
