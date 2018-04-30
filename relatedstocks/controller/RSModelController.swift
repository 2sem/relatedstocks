//
//  RSModelController.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 26..
//  Copyright © 2016년 leesam. All rights reserved.
//

import Foundation
import CoreData

class RSModelController : NSObject{
    struct EntityNames{
        static let RSStoredStock = "RSStoredStock";
        static let RSStoredKeyword = "RSStoredKeyword";
    }
    
    internal static let dispatchGroupForInit = DispatchGroup();
//    var SingletonQ = DispatchQueue(label: "RSModelController.Default");
    private static var _instance = RSModelController();
    static var Default : RSModelController{
        get{
            print("enter RSModelController instance - \(self) - \(Thread.current)");
            let value = _instance;
            
            print("wait RSModelController instance - \(self) - \(Thread.current)");
            self.dispatchGroupForInit.wait();
            print("exit RSModelController instance - \(self) - \(Thread.current)");
            
            return value;
        }
    }
    static let semaphore = DispatchSemaphore.init(value: 1);
//    {
//        get{
//            var value = self._instance;
//            objc_sync_enter(self)
//
//            defer { objc_sync_exit(self) }
//            print("return RSModelController instance");
//            return value;
//        }
//    }
    
    var context : NSManagedObjectContext;
    internal override init(){
         //lock on
//        objc_sync_enter(RSModelController.self)
//        print("begin init RSModelController - \(RSModelController.self) - \(Thread.current)");
        //get path for model file
        //xcdatamodel => momd??
        guard let model_path = Bundle.main.url(forResource: "RSModel", withExtension: "momd") else{
            fatalError("Can not find Model File from Bundle");
        }
        
        //load model from model file
        guard let model = NSManagedObjectModel(contentsOf: model_path) else {
            fatalError("Can not load Model from File");
        }
        
        //create store controller??
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model);
        
        //create data context
        self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType);
        //set store controller??
        self.context.persistentStoreCoordinator = psc;
        //lazy load??
//        var queue = DispatchQueue(label: "RSModelController.init", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil);
        DispatchQueue.global(qos: .background).async(group: RSModelController.dispatchGroupForInit) {
            print("begin init RSModelController");
//        DispatchQueue.main.async{
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask);
            
            //get path for app's url
            var docUrl = urls.last;
            //create path for data file
            docUrl?.appendPathComponent("RSModel");
            let storeUrl = docUrl;
            do {
                //set store type?
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]);
            } catch {
                
            }
            
            //lock off
//            objc_sync_exit(RSModelController.self);
//            RSModelController.semaphore.signal();
            //RSModelController.dispatchGroupForInit.leave();
            print("end init RSModelController");
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func waitInit(){
//        dispatchPrecondition(condition: .notOnQueue(<#T##DispatchQueue#>))
        while self.context.persistentStoreCoordinator?.persistentStores.isEmpty ?? false{
            sleep(1);
        }
    }
    
    
    
    func reset(){
        self.context.reset();
    }
    
    var isSaved : Bool{
        return !self.context.hasChanges;
    }
    
    func saveChanges(){
        do{
            try self.context.save();
        } catch {
            fatalError("Save failed Error(\(error))");
        }
    }
}
