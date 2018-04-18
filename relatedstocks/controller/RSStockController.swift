//
//  RSStockController.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 17..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit

/**
 [features]
 compay list for the keyword
 list of keyword
 favorite keywords
 favorite company
 
 [rest api]
 POST /stock/select
 {“keyword” : “KEYWORD1 KEYWORD2 …”}
 =>{“company1”:”COMPANY1”, “company2”:”COMPANY2” …. “company10”:”COMPANY10”}
 
 POST /stock/hotkeys
 => {“company1”:”COMPANY1”, “company2”:”COMPANY2” …. “company10”:”COMPANY10”}
 */

class RSStockController: NSObject {
//    typealias ListCompletionHandler = ([RSStockItem]?, NSError?) -> Void;
//    static let ServerURL = URL(string: "http://221.149.97.129:3000")!;
//    static let ServerURL = URL(string: "http://222.122.212.176:3000")!;
    static let ServerURL = URL(string: "http://andy3938.cafe24.com:3000")!;
    static let StockListURL = RSStockController.ServerURL.appendingPathComponent("stock/select");
    static let HotKeyListURL = RSStockController.ServerURL.appendingPathComponent("stock/hotkeys");
    
    static let MaxListCount = 10;
    
    private static var _instance = RSStockController();
    static var Default : RSStockController{
        get{
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            return self._instance;
        }
    }
    
    func requestKeywords(completion: (([RSStockKeyword]?, NSError?) -> Void)?){
        var req = URLRequest(url:  RSStockController.HotKeyListURL);
        req.setJSONPost();
        
//        var params = ["keyword": keyword];

        var json : String? = "{}";
        do{
            try req.httpBody = json?.data(using: .utf8);
//            json = try req.setJSONBody(withObject: params as NSObject);
            //            req.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted);
            //            json = String(data: req.httpBody!, encoding: .utf8);
            //            print("json => \(json)");
        }catch let error{
            print("json generation has been failed. error[\(error)]");
            return;
        }
        
        DispatchQueue.main.syncInMain {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        }
        print("stock server <= request \(req) "); //-> \(json ?? "")
        URLSession.shared.dataTask(with: req, completionHandler: {(data, res, error) -> Void in
            DispatchQueue.main.syncInMain {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false;
            }
            
            //let jsonData = data;
            var httpRes = res as? HTTPURLResponse;
            guard data != nil else{
                completion?(nil, error as NSError?);
                print("http error. error[\(error)]");
                return;
            }
            
            var jsonString = String(data: data ?? Data(), encoding: .utf8);
            var dict : [String : NSObject]? = [:];
            var translatedText : String?;
            var list : [RSStockKeyword] = [];
            
            do{
                var dict = try JSONSerialization.jsonObject(with: data!, options: [JSONSerialization.ReadingOptions.mutableContainers, .allowFragments]) as? [String : NSObject];
                
                for i in 1...RSStockController.MaxListCount{
                    var name = "company\(i)";
                    var company = dict?[name] as? String;
                    
                    if company?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false{
                        list.append(RSStockKeyword.init(company!));
                        print("\(name) > \(company)");
                    }
                }
            }catch let jsonError{
                print("json parsing error. error[\(jsonError)] json[\(jsonString)]");
            }
            completion?(list, error as NSError?);
            print("stock server => response \(httpRes?.statusCode) - \(jsonString)");
        }).resume();
    }
    
    func requestStocks(withKeyword keyword : String, completion: (([RSStockItem]?, NSError?) -> Void)?){
        var req = URLRequest(url:  RSStockController.StockListURL);
        req.setJSONPost();
        
        var params = ["keyword": keyword];
        
        var json : String? = "";
        do{
            json = try req.setJSONBody(withObject: params as NSObject);
//            req.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted);
//            json = String(data: req.httpBody!, encoding: .utf8);
            //            print("json => \(json)");
        }catch let error{
            print("json generation has been failed. error[\(error)]");
            return;
        }
        
        DispatchQueue.main.syncInMain {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        }
        print("stock server <= request \(req) -> \(json ?? "")");
        URLSession.shared.dataTask(with: req, completionHandler: {(data, res, error) -> Void in
            //let jsonData = data;
            DispatchQueue.main.syncInMain {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false;
            }
            var httpRes = res as? HTTPURLResponse;
            guard data != nil else{
                completion?(nil, error as NSError?);
                print("http error. error[\(error)]");
                return;
            }
            
            var jsonString = String(data: data ?? Data(), encoding: .utf8);
            var dict : [String : NSObject]? = [:];
            var translatedText : String?;
            var list : [RSStockItem] = [];
            
            do{
                var dict = try JSONSerialization.jsonObject(with: data!, options: [JSONSerialization.ReadingOptions.mutableContainers, .allowFragments]) as? [String : NSObject];
                
                for i in 1...RSStockController.MaxListCount{
                    var name = "company\(i)";
                    var company = dict?[name] as? String;
                    
                    if company?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false{
                        list.append(RSStockItem.init(company!));
                        print("\(name) > \(company)");
                    }
                }
            }catch let jsonError{
                print("json parsing error. error[\(jsonError)]");
            }
            completion?(list, error as NSError?);
            print("stock server => response \(httpRes?.statusCode) - \(jsonString)");
        }).resume();
    }
}
