//
//  RSStockItem.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 17..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit

class RSStockItem: NSObject {
    let name : String;
    let lastModified : Date;
    let code : String;
    let price : Int;
    let startPrice : Int;
    
    init(_ name : String, date: Date, code: String, price: Int, startPrice: Int) {
        self.name = name;
        self.lastModified = date;
        self.code = code;
        self.price = price;
        self.startPrice = startPrice;
    }
    
    convenience init(_ json: [String: AnyObject], index: Int) {
        let company = json["company\(index)"] as? String ?? "";
        print(json["datetime\(index)"] ?? "");
        //print((json["datetime\(index)"] ?? "").toDate("yyyy-M-dd HH:mm:ss"));
        let datetime = (json["datetime\(index)"] as? String ?? "").toDate("yyyy-M-dd HH:mm:ss") ?? Date();
        let code = json["code\(index)"] as? String ?? "";
        let price = Int(json["price\(index)"] as? String ?? "") ?? 0;
        let startPrice = Int(json["start_price\(index)"] as? String ?? "") ?? 0;
        
        self.init(company, date: datetime, code: code, price: price, startPrice: startPrice);
        
        print("stock\(index) name[\(company)] datetime[\(datetime)] code[\(code)] price[\(price)] startPrice[\(startPrice)]");
    }
}
