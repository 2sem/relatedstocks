//
//  LSFetchedResultsController.swift
//  relatedstocks
//
//  Created by 영준 이 on 2018. 4. 27..
//  Copyright © 2018년 leesam. All rights reserved.
//

import Foundation
import CoreData

class LSFetchedResultsController<Entity> : NSFetchedResultsController<NSFetchRequestResult> where Entity : NSFetchRequestResult{
    //let entityName : String;
    //let fetchController : NSFetchedResultsController<NSFetchRequestResult>!;
    var predicate: NSPredicate?{
        get{
            return self.fetchRequest.predicate;
        }
        set(value){
            self.fetchRequest.predicate = value;
            self.fetch();
        }
    }
    
    init(_ entityName: String, sortDescriptors: [NSSortDescriptor], moc : NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate? = nil) {
        //self.entityName = entityName;
        
        let request = NSFetchRequest<Entity>.init(entityName: entityName);
        request.sortDescriptors = sortDescriptors;
        
        //self.fetchController = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil);
        super.init(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil);
        self.delegate = delegate;
        
        self.fetch();
    }
    
    func fetch(){
        do{
            try self.performFetch();
        }catch let error{
            assertionFailure("Can not create fetcher for favorites. error[\(error.localizedDescription)]");
        }
    }
    
    func fetch(forSection section: Int, forIndex index: Int) -> Entity?{
        return self.object(at: IndexPath.init(row: index, section: section)) as? Entity;
    }
    
    var fetchedGroupCount : Int{
        return self.sections?.count ?? 0;
    }
    
    func fetchedCount(forGroup group: Int) -> Int{
        return self.sections?[group].numberOfObjects ?? 0;
    }
    
    func removeEntity(_ entity: Entity){
        self.managedObjectContext.delete(entity as! NSManagedObject);
        self.saveChanges();
    }
    
    func saveChanges(){
        let ctx = self.managedObjectContext;
        self.managedObjectContext.performAndWait { [weak ctx] in
            do{
                try ctx?.save();
                print("Saving favorite fetcher has been completed");
            } catch {
                assertionFailure("Saving favorite fetcher has been failed. Error(\(error))");
            }
        }
    }
}
