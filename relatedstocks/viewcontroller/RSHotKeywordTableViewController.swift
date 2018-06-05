//
//  RSHotKeywordTableViewController.swift
//  relatedstocks
//
//  Created by 영준 이 on 2017. 2. 14..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RSHotKeywordTableViewController: UIViewController {
    static let Cell_Id = "RSKeywordCell";
    
    //var keywords : [RSStockKeyword] = [];
    var selectedKeyword = BehaviorSubject<String>.init(value: "");
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        //self.updateKeywords();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.updateKeywords();
    }
    
    var keywordsDisposeBag = DisposeBag();
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = nil;
        self.tableView.delegate = nil;
        
        RSStockController.shared.requestKeywords()
            .map({ (result) -> [RSStockKeyword] in
                switch result{
                case .Success(let keywords):
                    return keywords;
                case .Error(let error):
                    self.openInternetError();
                    return [];
                }
            })
            .bindTableView(to: self.tableView, cellIdentifier: type(of: self).Cell_Id, cellType: RSHotKeywordTableViewCell.self) { (row, keyword, cell) in
                cell.keywordLabel?.text = keyword.name;
                cell.showNewIndicator = keyword.isLastest;
                print("print keyword cell. keyword[\(cell.textLabel?.text ?? "")] isLastest[\(keyword.isLastest)]");
                
            }.disposed(by: self.keywordsDisposeBag);
        
        self.tableView.rx.modelSelected(RSStockKeyword.self)
            .subscribe(onNext: { [weak self](keyword) in
                guard self != nil else{
                    return;
                }
                
                self?.selectedKeyword.onNext(keyword.name ?? "");
            }, onError: nil)
        .disposed(by: self.keywordsDisposeBag);
    }
    
    func updateKeywords(){
        RSStockController.shared.requestKeywords();
        
        //        refreshControl.isRefreshing = true;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
