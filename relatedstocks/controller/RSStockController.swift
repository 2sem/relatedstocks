//
//  RSStockController.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 17..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit
import LSExtensions
import RxCocoa
import RxSwift
import Alamofire

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
    static let plistName = "relatedstocks";
    
    static func property(_ name: String) -> String{
        guard let plist = Bundle.main.path(forResource: self.plistName, ofType: "plist") else{
            preconditionFailure("Please create plist file named of \(UIApplication.shared.displayName ?? ""). file[\(self.plistName).plist]");
        }
        
        guard let dict = NSDictionary.init(contentsOfFile: plist) as? [String : String] else{
            preconditionFailure("Please \(self.plistName).plist is not Property List.");
        }
        
        return dict[name] ?? "";
    }
    
    static var stocksPort : Int = {
        return Int(property("StocksPort")) ?? 0;
    }()
    static var stocksUrl : URL! = {
        return URL(string: "\(property("ServerURL")):\(stocksPort)");
    }()
    static var pushPort : Int = {
        return Int(property("PushPort")) ?? 0;
    }()
    static var PushUrl : URL! = {
        return URL(string: "\(property("ServerURL")):\(pushPort)");
    }()
    
    static let StockListURL = RSStockController.stocksUrl.appendingPathComponent("stock/select");
    static let HotKeyListURL = RSStockController.stocksUrl.appendingPathComponent("stock/hotkeys");
    static let PushRegURL = RSStockController.PushUrl.appendingPathComponent("devices/insert");
    
    static let MaxListCount = 10;

    static let shared = RSStockController();
    
    private let keywordsSubject = BehaviorSubject<Bool>(value: false);
    func requestKeywords() -> Observable<[RSStockKeyword]>{
        //.distinctUntilChanged()
        self.keywordsSubject.onNext(true);
        return self.keywordsSubject.asObservable()
            .flatMapLatest({ (flag) -> Observable<[RSStockKeyword]> in
                print("flag changed to query from server. keyword[\(flag)]");
                
                return RSStockController.shared._requestKeywords();
            })
    }
    
    private func _requestKeywords() -> Observable<[RSStockKeyword]>{
        UIApplication.onNetworking();
        
        return Observable<[RSStockKeyword]>.create({ (observer) -> Disposable in
            let params : [String : String] = [:];
            print("search hot keywords");
            let task = Alamofire.request(RSStockController.HotKeyListURL, method: .post, parameters: params).responseJSON(options: .allowFragments) { (res) in
                UIApplication.offNetworking();
                print("stock server => response[\(res.response?.statusCode.description ?? "")]");
                
                guard let json = res.value as? [String : String] else{
                    observer.onError(URLError.notConnectedToInternet as! Error);
                    observer.onCompleted();
                    return;
                }
                
                var list : [RSStockKeyword] = [];
                for i in 1...RSStockController.MaxListCount{
                    let name = "company\(i)";
                    guard let company = json[name] else{
                        continue;
                    }
                    
                    if company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false{
                        list.append(RSStockKeyword.init(company));
                        print("\(name) > \(company)");
                    }
                }
                observer.onNext(list);
                observer.onCompleted();
            }
            
            return Disposables.create {
                task.cancel();
            }
        })
    }
    
    //, completion: (([RSStockItem]?, NSError?) -> Void)?
    private let stocksKeyword = BehaviorSubject<String>(value: "");
    
    func requestStocks(withKeyword keyword : String) -> Observable<[RSStockItem]>{
        //.distinctUntilChanged()
        self.stocksKeyword.onNext(keyword);
        return self.stocksKeyword.asObservable().distinctUntilChanged()
        .flatMapLatest({ (text) -> Observable<[RSStockItem]> in
                print("keyword changed to query from server. keyword[\(text)]");

                guard text.any else{
                    print("empty keyword return empty array");
                    return Observable<[RSStockItem]>.from(optional: []);
                }
                
                return RSStockController.shared._requestStocks(withKeyword: text);
        })
    }
    private func _requestStocks(withKeyword keyword : String) -> Observable<[RSStockItem]>{
        UIApplication.onNetworking();
        
        return Observable<[RSStockItem]>.create({ (observer) -> Disposable in
            let params = ["keyword": keyword];
            print("search with keyword[\(keyword)]");
            let task = Alamofire.request(RSStockController.StockListURL, method: .post, parameters: params).responseJSON(options: .allowFragments) { (res) in
                UIApplication.offNetworking();
                print("stock server => response[\(res.response?.statusCode.description ?? "")]");
                
                guard let json = res.value as? [String : String] else{
                    observer.onError(URLError.notConnectedToInternet as! Error);
                    observer.onCompleted();
                    return;
                }
                
                var list : [RSStockItem] = [];
                for i in 1...RSStockController.MaxListCount{
                    let name = "company\(i)";
                    guard let company = json[name] else{
                        continue;
                    }
                    
                    if company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false{
                        list.append(RSStockItem.init(company));
                        print("\(name) > \(company)");
                    }
                }
                observer.onNext(list);
                observer.onCompleted();
            }
            
            return Disposables.create {
                task.cancel();
            }
        })
        
        /*var json : String? = "";
        do{
            json = try req.setJSONBody(withObject: params as NSObject);
//            req.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted);
//            json = String(data: req.httpBody!, encoding: .utf8);
            //            print("json => \(json)");
        }catch let error{
            print("json generation has been failed. error[\(error)]");
            return self.keywordsRelay;
        }*/
        
        
        
        //print("stock server <= request \(req) -> \(json ?? "")");
        /*URLSession.shared.dataTask(with: req, completionHandler: {(data, res, error) -> Void in
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
        }).resume();*/        
    }
}
