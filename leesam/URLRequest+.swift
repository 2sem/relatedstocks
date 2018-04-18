//
//  URLRequest+.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 22..
//  Copyright © 2016년 leesam. All rights reserved.
//

import Foundation

extension URLRequest{
    mutating func setJSONPost(){
        if self.value(forHTTPHeaderField: "Content-Type") == nil{
            self.addValue("application/json;", forHTTPHeaderField: "Content-Type");
        }else{
            self.setValue("application/json;", forHTTPHeaderField: "Content-Type");
        }
        self.httpMethod = "POST";
    }
    
    mutating func setJSONBody(withObject obj: NSObject, encoding: String.Encoding = String.Encoding.utf8) throws -> String? {
        var value : String?;
        
        self.httpBody = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted);
        value = String(data: self.httpBody!, encoding: .utf8);
        
        return value;
    }
}
