//
//  RSModelController+RSStoredStock.swift
//  relatedstocks
//
//  Created by 영준 이 on 2017. 2. 14..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData

extension RSModelController{
    func loadStocks(predicate : NSPredicate? = nil, sortWays: [NSSortDescriptor]? = [], completion: (([RSStoredStock], NSError?) -> Void)? = nil) -> [RSStoredStock]{
        //        self.waitInit();
        print("begin to load from \(self.classForCoder)");
        var values : [RSStoredStock] = [];
        
        let requester = NSFetchRequest<NSFetchRequestResult>(entityName: EntityNames.RSStoredStock);
        requester.predicate = predicate;
        requester.sortDescriptors = sortWays;
        
        //        requester.predicate = NSPredicate(format: "name == %@", "Local");
        
        do{
            values = try self.context.fetch(requester) as! [RSStoredStock];
            print("fetch stocks with predicate[\(predicate)] count[\(values.count)]");
            completion?(values, nil);
        } catch let error{
            fatalError("Can not load Stocks from DB");
        }
        
        return values;
    }
    
    func isExistStocks(withName name : String) -> Bool{
        var predicate = NSPredicate(format: "name == \"\(name)\"");
        return !self.loadStocks(predicate: predicate, sortWays: nil).isEmpty;
    }
    
    func findStocks(withName name : String) -> [RSStoredStock]{
        var predicate = NSPredicate(format: "name == \"\(name)\"");
        return self.loadStocks(predicate: predicate, sortWays: nil);
    }
    
    @discardableResult
    func createStock(name: String, keyword: String) -> RSStoredStock{
        let stock = NSEntityDescription.insertNewObject(forEntityName: EntityNames.RSStoredStock, into: self.context) as! RSStoredStock;
        
        stock.name = name;
        stock.keyword = keyword;
        
        return stock;
    }
    
    func removeStock(stock: RSStoredStock){
        self.context.delete(stock);
    }
    
    func refreshStock(stock: RSStoredStock){
        self.context.refresh(stock, mergeChanges: false);
    }
}
