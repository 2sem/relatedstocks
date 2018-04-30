//
//  NSFetchedResultsController+Observable.swift
//  relatedstocks
//
//  Created by 영준 이 on 2018. 4. 27..
//  Copyright © 2018년 leesam. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import RxCocoa

extension NSFetchedResultsController: ReactiveCompatible{
    /*public var rx: Reactive<NSFetchedResultsController<ResultType>>{
        return RxNSFetchedResultsController.init(self as! NSFetchedResultsController<NSFetchRequestResult>);
    }*/
}

/*struct RxNSFetchedResultsController: Reactive<NSFetchedResultsController<ResultType>>{
    var controller: NSFetchedResultsController<NSFetchRequestResult>;
    
    init(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.controller = controller;
    }
}*/

//extension RxNSFetchedResultsController{
extension Reactive where Base: NSFetchedResultsController<NSFetchRequestResult>{
    // where Sequence: Sequence
    func asRelay<Entity>(_ entityType: Entity.Type) -> BehaviorRelay<[Entity]> where Entity: NSFetchRequestResult{
        let sequence = RxNSFetchedResultsSequence.init(self as! Reactive<NSFetchedResultsController<Entity>>, entityType: Entity.self);
        let array : [Entity] = [Entity].init(sequence);
        //RxNSFetchedResultsSequence.init(self, entityType: Entity.self)
        return BehaviorRelay<[Entity]>.init(value: array);
    }
}

class RxNSFetchedResultsSequence<Entity>: NSObject, Sequence where Entity: NSFetchRequestResult{
    typealias Element = Entity;
    
    private var rx: Reactive<NSFetchedResultsController<Entity>>;
    init(_ rx : Reactive<NSFetchedResultsController<Entity>>, entityType: Entity.Type){
        self.rx = rx;
        super.init();
    }
    
    func makeIterator() -> RxNSFetchedResultsIterator<Entity> {
        return RxNSFetchedResultsIterator.init(self.rx, entityType: Entity.self);
    }
}

class RxNSFetchedResultsIterator<Entity>: NSObject, IteratorProtocol where Entity: NSFetchRequestResult {
    typealias Element = Entity;
    
    private var currentIndex: Int = 0;
    private var rx: Reactive<NSFetchedResultsController<Entity>>;
    init(_ rx : Reactive<NSFetchedResultsController<Entity>>, entityType: Entity.Type) {
        self.rx = rx;
        super.init();
    }
    
    private var count : Int{
        return self.rx.base.sections?[0].numberOfObjects ?? 0;
    }
    
    private func fetchObject(_ indexPath: IndexPath) -> Entity{
        return self.rx.base.object(at: indexPath);
    }
    
    func next() -> Entity? {
        var value : Entity?;
        guard self.currentIndex < self.count else{
            return value;
        }
        value = self.fetchObject(IndexPath.init(row: self.currentIndex, section: 0));
        self.currentIndex += 1;
        
        return value;
    }
}
