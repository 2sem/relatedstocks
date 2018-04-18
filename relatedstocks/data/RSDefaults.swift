//
//  RSDefaults.swift
//  relatedstocks
//
//  Created by 영준 이 on 2017. 3. 17..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

class RSDefaults{
    static var Defaults : UserDefaults{
        get{
            return UserDefaults.standard;
        }
    }
    
    class Keys{
        static let LastFullADShown = "LastFullADShown";
        static let LastRewardADShown = "LastRewardADShown";
        static let LastShareShown = "LastShareShown";
    }
    
    static var LastFullADShown : Date{
        get{
            var seconds = Defaults.double(forKey: Keys.LastFullADShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastFullADShown);
        }
    }
    
    static var LastRewardADShown : Date{
        get{
            var seconds = Defaults.double(forKey: Keys.LastRewardADShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastRewardADShown);
        }
    }
    
    static var LastShareShown : Date{
        get{
            var seconds = Defaults.double(forKey: Keys.LastShareShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastShareShown);
        }
    }
}
