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
    
    public enum QueryResult<T>{
        case Success([T])
        case Error(Error)
        var isError : Bool{
            var value = false;
            
            switch self{
                case .Error(_):
                    value = true;
                    break;
                default:
                    break;
            }
            
            return value;
        }
    }
    
    private let keywordsSubject = BehaviorSubject<Bool>(value: false);
    func requestKeywords() -> Observable<QueryResult<RSStockKeyword>>{
        //.distinctUntilChanged()
        self.keywordsSubject.onNext(true);
        return self.keywordsSubject.asObservable()
            .flatMapLatest({ (flag) -> Observable<QueryResult<RSStockKeyword>> in
                print("flag changed to query from server. keyword[\(flag)]");
                
                return RSStockController.shared._requestKeywords();
            })
    }
    
    private func _requestKeywords() -> Observable<QueryResult<RSStockKeyword>>{
        UIApplication.onNetworking();
        
        return Observable<QueryResult<RSStockKeyword>>.create({ (observer) -> Disposable in
            let params : [String : String] = [:];
            print("search hot keywords");
            let task = Alamofire.request(RSStockController.HotKeyListURL, method: .post, parameters: params).responseJSON(options: .allowFragments) { (res) in
                UIApplication.offNetworking();
                print("stock server => response[\(res.response?.statusCode.description ?? "")]");
                switch res.result{
                    case .success(let data):
                        guard let json = data as? [String : AnyObject] else{
                            observer.onNext(QueryResult<RSStockKeyword>.Error(URLError.notConnectedToInternet.error));
                            observer.onCompleted();
                            return;
                        }
                        
                        var list : [RSStockKeyword] = [];
                        for i in 1...RSStockController.MaxListCount{
                            let keyword = RSStockKeyword.init(json, index: i);
                            guard let name = keyword.name, name.any else{
                                continue;
                            }
                            
                            list.append(keyword);
                        }
                        list.max{ $0.lastModified < $1.lastModified }?.isLastest = true;
                        
                        observer.onNext(QueryResult<RSStockKeyword>.Success(list));
                        observer.onCompleted();
                        break;
                    case .failure(let error):
                        observer.onNext(QueryResult<RSStockKeyword>.Error(error));
                        observer.onCompleted();
                        return;
                }
            }
            
            return Disposables.create {
                task.cancel();
            }
        })
    }
    
    //, completion: (([RSStockItem]?, NSError?) -> Void)?
    private let stocksKeyword = BehaviorSubject<String>(value: "");
    
    func requestStocks(withKeyword keyword : String) -> Observable<QueryResult<RSStockItem>>{
        //.distinctUntilChanged()
        self.stocksKeyword.onNext(keyword);
        return self.stocksKeyword.asObservable()
        .flatMapLatest({ (text) -> Observable<QueryResult<RSStockItem>> in
                print("keyword changed to query from server. keyword[\(text)]");

                guard text.any else{
                    print("empty keyword return empty array");
                    return Observable<QueryResult<RSStockItem>>
                        .from(optional: QueryResult<RSStockItem>.Success([]));
                }
                
                return RSStockController.shared._requestStocks(withKeyword: text);
        })
    }
    private func _requestStocks(withKeyword keyword : String) -> Observable<QueryResult<RSStockItem>>{
        UIApplication.onNetworking();
        
        return Observable<QueryResult<RSStockItem>>.create({ (observer) -> Disposable in
            let params = ["keyword": keyword];
            print("search with keyword[\(keyword)]");
            let task = Alamofire.request(RSStockController.StockListURL, method: .post, parameters: params).responseJSON(options: .allowFragments) { (res) in
                UIApplication.offNetworking();
                print("stock server => response[\(res.response?.statusCode.description ?? "")]");
                print("response => %s", res.value.debugDescription);
                guard let json = res.value as? [String : AnyObject] else{
                    observer.onNext(QueryResult<RSStockItem>.Error(URLError.notConnectedToInternet.error));
                    observer.onCompleted();
                    return;
                }
                
                var list : [RSStockItem] = [];
                for i in 1...RSStockController.MaxListCount{
                    var name = "company\(i)";
                    let stock = RSStockItem.init(json, index: i);
                    guard stock.name.any else{
                        continue;
                    }
                    
                    list.append(stock);
                }
                observer.onNext(QueryResult<RSStockItem>.Success(list));
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
