//
//  LSFetchedResultsController.swift
//  relatedstocks
//
//  Created by 영준 이 on 2018. 4. 27..
//  Copyright © 2018년 leesam. All rights reserved.
//

import Foundation
import CoreData

class LSFetchedResultsController<Entity> : NSObject where Entity : NSManagedObject{
    //let entityName : String;
    let fetchController : NSFetchedResultsController<NSFetchRequestResult>!;
    var predicate: NSPredicate?{
        get{
            return self.fetchController.fetchRequest.predicate;
        }
        set(value){
            self.fetchController.fetchRequest.predicate = value;
        }
    }
    
    init(_ entityName: String, entityType: Entity.Type, sortDescriptors: [NSSortDescriptor], moc : NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate? = nil) {
        //self.entityName = entityName;
        
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: entityName);
        request.sortDescriptors = sortDescriptors;
        
        self.fetchController = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil);
        self.fetchController.delegate = delegate;
        super.init();
        
        self.fetch();
    }
    
    func fetch(){
        do{
            try self.fetchController?.performFetch();
        }catch let error{
            assertionFailure("Can not create fetcher for favorites. error[\(error.localizedDescription)]");
        }
    }
    
    func fetch(forSection section: Int, forIndex index: Int) -> Entity?{
        return self.fetchController.object(at: IndexPath.init(row: index, section: section)) as? Entity;
    }
    
    var fetchedGroupCount : Int{
        return self.fetchController.sections?.count ?? 0;
    }
    
    func fetchedCount(forGroup group: Int) -> Int{
        return self.fetchController.sections?[group].numberOfObjects ?? 0;
    }
    
    func removeEntity(_ entity: Entity){
        self.fetchController.managedObjectContext.delete(entity);
        self.saveChanges();
    }
    
    func saveChanges(){
        let ctx = self.fetchController?.managedObjectContext;
        self.fetchController?.managedObjectContext.performAndWait { [weak ctx] in
            do{
                try ctx?.save();
                print("Saving favorite fetcher has been completed");
            } catch {
                assertionFailure("Saving favorite fetcher has been failed. Error(\(error))");
            }
        }
    }
}
