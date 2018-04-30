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
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: type(of: self).Cell_Id);
        
        RSStockController.shared.requestKeywords().bindTableView(to: self.tableView, cellIdentifier: type(of: self).Cell_Id, cellType: UITableViewCell.self) { (row, keyword, cell) in
            cell.textLabel?.text = keyword.name;
            print("print keyword cell. keyword[\(cell.textLabel?.text ?? "")]");
            
            let pointSize = CGFloat(17.0);
            cell.textLabel?.font = cell.textLabel?.font.withSize(pointSize);
            cell.textLabel?.textColor = UIColor.blue;
            cell.textLabel?.highlightedTextColor = UIColor.gray;
            cell.textLabel?.textAlignment = .center;
            cell.selectionStyle = .none;
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
        //        refreshControl.isRefreshing = true;
        RSStockController.shared.requestKeywords();
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
