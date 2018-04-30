//
//  ObservableType+UITableView.swift
//  letscheers
//
//  Created by 영준 이 on 2018. 4. 12..
//  Copyright © 2018년 leesam. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Observable where Element: Sequence{
    typealias ElementType = Element.Iterator.Element;
    //func bindTable<Cell>(to: UITableView, cellIdentifier: String, cellType: Cell.Type, cellGenerator:  @escaping (UITableView, ElementType, Cell) -> Disposable){
    /**
     support completion for binding obervable sequence to tableView.rx.items
     
     - parameter cellIdentifier: Identifier used to dequeue cells.
     - parameter cellType: Type of table view cell.
     - parameter cellGernerator: configurator table view cell.
         - parameter cellRow: Row index of table view cell.
         - parameter element: element of sequence.
         - parameter cell: generated table view cell.
     - returns: generated disposeBag.
     
     Example:
     
     let items = Observable.just([
     "First Item",
     "Second Item",
     "Third Item"
     ])
     
     items
     .bindTable(to: tableView, cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
     cell.textLabel?.text = "\(element) @ row \(row)"
     }
     .disposed(by: disposeBag)
     */
    func bindTableView<TableCell>(to: UITableView, cellIdentifier: String, cellType: TableCell.Type,
        cellConfigurator:  @escaping (_ cellRow: Int, _ element: ElementType, TableCell) -> Void) -> Disposable where TableCell: UITableViewCell{
        let value = self.bind(to: to.rx.items(cellIdentifier: cellIdentifier, cellType: TableCell.self)){ (row, category, cell) in
            //cellGenerator(tableView, category, cell);
            cellConfigurator(row, category, cell);
        }
        
        return value;
    }
}
