//
//  RSModelController+RSStoredKeyword.swift
//  relatedstocks
//
//  Created by 영준 이 on 2017. 2. 14..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData

extension RSModelController{
    func loadKeywords(predicate : NSPredicate? = nil, sortWays: [NSSortDescriptor]? = [], completion: (([RSStoredKeyword], NSError?) -> Void)? = nil) -> [RSStoredKeyword]{
        //        self.waitInit();
        print("begin to load from \(self.classForCoder)");
        var values : [RSStoredKeyword] = [];
        
        let requester = NSFetchRequest<NSFetchRequestResult>(entityName: EntityNames.RSStoredKeyword);
        requester.predicate = predicate;
        requester.sortDescriptors = sortWays;
        
        //        requester.predicate = NSPredicate(format: "name == %@", "Local");
        
        do{
            values = try self.context.fetch(requester) as! [RSStoredKeyword];
            print("fetch keywords with predicate[\(predicate)] count[\(values.count)]");
            completion?(values, nil);
        } catch let error{
            fatalError("Can not load Keywords from DB");
        }
        
        return values;
    }

    func isExistKeywords(withName name : String) -> Bool{
        var predicate = NSPredicate(format: "name CONTAINS \"\(name)\"");
        return !self.loadKeywords(predicate: predicate, sortWays: nil).isEmpty;
    }

    func findKeywords(withName name : String) -> [RSStoredKeyword]{
        var predicate = NSPredicate(format: "name CONTAINS \"\(name)\"");
        return self.loadKeywords(predicate: predicate, sortWays: nil);
    }

    @discardableResult
    func createKeyword(name: String) -> RSStoredKeyword{
        let keyword = NSEntityDescription.insertNewObject(forEntityName: EntityNames.RSStoredKeyword, into: self.context) as! RSStoredKeyword;
        
        keyword.name = name;
        
        return keyword;
    }

    func removeKeyword(keyword: RSStoredKeyword){
        self.context.delete(keyword);
    }

    func refreshKeyword(keyword: RSStoredKeyword){
        self.context.refresh(keyword, mergeChanges: false);
    }
}
