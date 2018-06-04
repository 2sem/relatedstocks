//
//  RSStockKeyword.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 24..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit

class RSStockKeyword: NSObject {
    var name : String?;
    let lastModified : Date;
    var isLastest : Bool = false;
    
    init(_ name : String, date: Date) {
        self.name = name;
        self.lastModified = date;
    }
    
    convenience init(_ json: [String: String], index: Int) {
        let company = json["company\(index)"];
        print(json["datetime\(index)"] ?? "");
        print((json["datetime\(index)"] ?? "").toDate("yyyy-M-dd HH:mm:ss"));
        let datetime = (json["datetime\(index)"] ?? "").toDate("yyyy-M-dd HH:mm:ss") ?? Date();
        
        self.init(company!, date: datetime);
        
        print("keyword\(index) name[\(company)] datetime[\(datetime)]");
    }
}
