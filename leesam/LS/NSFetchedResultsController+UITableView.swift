//
//  NSFetchedResultsController+UITableView.swift
//  letscheers
//
//  Created by 영준 이 on 2018. 4. 26..
//  Copyright © 2018년 leesam. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/**
    this is container for lx
 */
class LsFetcherContainer : NSObject{
    weak var controller : NSFetchedResultsController<NSFetchRequestResult>!;

    init(_ controller : NSFetchedResultsController<NSFetchRequestResult>) {
        self.controller = controller;
    }
}

/**
     UITableViewDataSource generated by lx automatically to provide entities fetched by NSFetchedResultController
*/
class LsFetchTableViewDataSource<Entity, TableCell> : NSObject, UITableViewDataSource where Entity: NSManagedObject, TableCell: UITableViewCell{
    internal weak var controller: NSFetchedResultsController<NSFetchRequestResult>!;
    private var cellGenerator: (_ cellPath: IndexPath, _ element: Entity, TableCell) -> Void;
    private var cell_Id: String = "";
    /**
        Default Behavior for deleting
    */
    private var cellRemover: ((_ cellPath: IndexPath, _ element: Entity, TableCell) -> Void)!;
    
    /**
        Indication whether it is possible to delete entities by deleting row
    */
    private(set) var canDelete : Bool = true;
    
    /**
         Sets the indication whether it is possible to delete entities by deleting row
         - parameter value: new value for indication
    */
    func setRemovable(_ value: Bool){
        self.canDelete = value;
    }
    
    init(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                  type: Entity.Type, cellType: TableCell.Type, cell_id: String,
                  generator: @escaping (_ cellPath: IndexPath, _ entity: Entity, _ cell: TableCell) -> Void) {
                            //@escaping (_ cellPath: IndexPath, _ element: Entity.Type, _ cell: TableCell) -> Void)
        self.controller = controller;
        self.cell_Id = cell_id;
        self.cellGenerator = generator;
        // Sets default behavior for deleting row
        super.init();
        self.cellRemover = self.defaultRemover;
    }
    
    /**
        Default behavior for deleting cell
    */
    private func defaultRemover(_ cellPath: IndexPath, _ entity: Entity, _ cell: TableCell) -> Void{
        controller.managedObjectContext.performAndWait {
            do{
                controller.managedObjectContext.delete(entity);
                try controller.managedObjectContext.save();
            }catch{
                
            }
        }
    }
    
    // MARK: UITableViewDataSource
    internal func numberOfSections(in tableView: UITableView) -> Int {
        let value = self.controller.sections?.count ?? 0
        print("fetched sections count[\(value)]. entity[\(Entity.self.description())]");
        
        return value;
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let value = self.controller.sections?[section].numberOfObjects ?? 0;
        print("fetched row count[\(value)] section[\(section)] entity[\(Entity.description())]");
        
        return value;
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cell_Id, for: indexPath) as? TableCell else{
            preconditionFailure("Can not dequeue cell for indexPath[\(indexPath.description)] entity[\(Entity.self.description())]");
        }
        
        guard let entity = self.controller.object(at: indexPath) as? Entity else{
            preconditionFailure("Can not get entity for indexPath[\(indexPath.description)] entity[\(Entity.self.description())]");
        }
        
        print("Generates cell from fetched row. indexPath[\(indexPath)] entity[\(entity.description)]");
        self.cellGenerator(indexPath, entity, cell);
        
        return cell;
    }
    
    internal func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.canDelete;
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let entity = self.controller.object(at: indexPath) as? Entity else{
                return;
            }
            
            self.controller.managedObjectContext.performAndWait {
                do{
                    self.controller.managedObjectContext.delete(entity);
                    try self.controller.managedObjectContext.save();
                }catch{
                    
                }
            }
            
        }else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}


extension NSFetchedResultsController{
    /**
        Generate lx container to binding this to UI
    */
    @objc var ls : LsFetcherContainer{
        get{
            return LsFetcherContainer(self as! NSFetchedResultsController<NSFetchRequestResult>); //
        }
    }
}

extension LsFetcherContainer{
    /**
         Bind NSFetchedResultsController to UITableView
         - requires: dataSource of given UITableView should be nil
         - parameter to: UITableView to bind
         - parameter cellIdentifier: Reusable Cell Identifier
         - parameter entityType: type of entity will be fetched by NSFetchedResultsController
         - parameter cellType: type of cell will be generated by this binding
         - parameter cellConfigurator: block to configure generated cell
         - parameter cellPath: IndexPath of generated cell
         - parameter entity: Entity fetched by NSFetchedResultsController with IndexPath
         - parameter cell: generated cell to configure
         - returns: Generated dataSource, You should hold this to keep binding
     
         - note: Example:
     
     self.dataSource = self.fetchController.lx.bindTableView(to: self.tableView, cellIdentifier: type(of: self).CellID, entityType: FavoriteToast.self, cellType: LCToastTableViewCell.self) { (index, fav, cell) in
         cell.nameLabel.text = fav.name;
         cell.contentLabel.text = fav.contents;
     }
     */
    func bindTableView<Entity, TableCell>(to: UITableView, cellIdentifier: String, entityType: Entity.Type, cellType: TableCell.Type
        , cellConfigurator:  @escaping (_ cellPath: IndexPath, _ entity: Entity, _ cell: TableCell) -> Void) -> LsFetchTableViewDataSource<Entity, TableCell> where Entity: NSManagedObject, TableCell: UITableViewCell{
        //LxFetchTableViewDataSource.init
        let value = LsFetchTableViewDataSource.init(self.controller, type: Entity.self, cellType: TableCell.self, cell_id: cellIdentifier, generator: cellConfigurator);
        assert(to.dataSource == nil, "Target UITableView already has dataSource. cellIdentifier[\(cellIdentifier)]");
        to.dataSource = value;
        
        return value;
    }
}

