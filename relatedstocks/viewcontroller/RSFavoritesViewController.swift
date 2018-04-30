//
//  RSFavoritesViewController.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 27..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa

class RSFavoritesViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    static let Cell_Id = "RSSearchCell";

    var stocks : [RSStoredStock] = [];
    var editButton : UIBarButtonItem!;
    var doneButton : UIBarButtonItem!;
    var cancelButton : UIBarButtonItem!;
    
    lazy var fetchedResultsController : LSFetchedResultsController<RSStoredStock> = {
        var moc : NSManagedObjectContext!;

        DispatchQueue.main.syncInMain {
            moc = RSModelController.Default.context;
        }
        
        return LSFetchedResultsController.init("RSStoredStock", entityType: RSStoredStock.self, sortDescriptors: [NSSortDescriptor.init(key: "name", ascending: true)], moc: moc);
    }();
    //Rx Source for UITableView
    //var fetchedResults: BehaviorRelay<[RSStoredStock]>!;

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.refresh();
        
        guard ReviewManager.shared?.canShow ?? false else{
            //self.fullAd?.show();
            return;
        }
        ReviewManager.shared?.show();
    }
    
    var dataSource : UITableViewDataSource?;
    //var disposeBag = DisposeBag();
    override func viewDidLoad() {
        super.viewDidLoad()

        //Bind NSFetchedResultsController to UITableView
        self.tableView.dataSource = nil;
        self.dataSource = self.fetchedResultsController.fetchController.ls.bindTableView(to: self.tableView, cellIdentifier: type(of: self).Cell_Id, entityType: RSStoredStock.self, cellType: RSSearchCell.self, cellConfigurator: { (indexPath, entity, cell) in
            cell.iconImage.image = UIImage(named: "stock.png");
            cell.titleLabel?.text = entity.name;
        });
        self.fetchedResultsController.fetchController.delegate = self;
        
        // Implements with rxCocoa
        /*self.disposeBag = self.fetchedResultsController.fetchController.rx.asRelay(RSStoredStock.self)
            .asObservable().bindTableView(to: self.tableView, cellIdentifier: type(of: self).Cell_Id, cellType: RSSearchCell.self) { (index, entity, cell) in
                print("create favorite cell. name[\(entity.name ?? "")]");
            cell.iconImage.image = UIImage(named: "stock.png");
            cell.titleLabel?.text = entity.name;
        }
        
        self.tableView.rx.itemDeleted.subscribe { (indexPath) in
            print("will remove entity");
        }.disposed(by: self.disposeBag);
        
        self.setEditButton();*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(){
        self.stocks = RSModelController.Default.loadStocks();
//        self.tableView.reloadData();
        self.tableView.reloadSections(IndexSet.init(integer: 0), with: .automatic);
    }
    
    internal func setEditButton(){
        if self.editButton == nil{
//            self.editButton = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(onBeginEdit(button:)));
            self.editButton = UIBarButtonItem.init(title: "수정", style: .plain, target: self, action: #selector(onBeginEdit(button:)));
        }
        self.navigationItem.rightBarButtonItem = self.editButton;
    }
    
    @IBAction func onBeginEdit(button : UIBarButtonItem){
        self.tableView.setEditing(true, animated: true);
        if self.doneButton == nil{
//            self.doneButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(onEndEdit(button:)));
            self.doneButton = UIBarButtonItem.init(title: "완료", style: .plain, target: self, action: #selector(onEndEdit(button:)));
        }
        self.navigationItem.rightBarButtonItem = self.doneButton;
        
        if self.cancelButton == nil{
//            self.cancelButton = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(onCancelEdit(button:)));
            self.cancelButton = UIBarButtonItem.init(title: "취소", style: .plain, target: self, action: #selector(onCancelEdit(button:)));
        }
        self.navigationItem.leftBarButtonItem = self.cancelButton;
    }
    
    @IBAction func onEndEdit(button : UIBarButtonItem){
        self.setEditButton();
        self.tableView.setEditing(false, animated: true);
        self.navigationItem.leftBarButtonItem = nil;
        RSModelController.Default.saveChanges();
    }
    
    @IBAction func onCancelEdit(button : UIBarButtonItem){
        var needToReload = !RSModelController.Default.isSaved;
        RSModelController.Default.reset();
        defer{
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = self.editButton;
            self.tableView.setEditing(false, animated: true);
        }
        guard needToReload else{
            return;
        }
        self.refresh();
//        DispatchQueue.main.async {
        
//        }
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
            case .delete:
                guard let indexPath = indexPath else{
                    return;
                }
                
                self.tableView.deleteRows(at: [indexPath], with: .fade);
                break;
            case .insert:
                guard let newIndexPath = newIndexPath else{
                    return;
                }
                self.tableView.insertRows(at: [newIndexPath], with: .fade);
                break;
            default:
                break;
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let internetView = segue.destination as? RSInternetViewController{
            let cell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as? RSSearchCell;
            let company = cell?.titleLabel?.text;
            internetView.company = company!;
        }
    }
}
