//
//  RSSearchTableViewController.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 16..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit
import LSExtensions
import CoreData
import RxSwift
import RxCocoa

class RSSearchTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, RSKeywordTableViewDelegate,  NSFetchedResultsControllerDelegate {

    static let Cell_Id = "RSSearchCell";
    
    /**
     Search Results Smaple: [RSStockItem("우리들제약"), RSStockItem("바른손"), RSStockItem("위노바"), RSStockItem("서희건설"), RSStockItem("에이연희"), RSStockItem("궁일신동")];
    */
    //var searchResults : [RSStockItem] = [];
    
    /**
        Recommended keywords to search stock items
    */
    var keywords : [RSStockKeyword] = [];
    
    private(set) static var shared : RSSearchTableViewController?;
    
    /**
        Keyword to search by Kakao-Link or Push Notification
    */
    static var startingKeyword = ""{
        didSet{
            RSSearchTableViewController.shared?.navigationController?.popViewController(animated: true);
            RSSearchTableViewController.shared?.search(withKeyword: startingKeyword);
            RSSearchTableViewController.shared?.searchBar.text = startingKeyword;
        }
    }
    
    var searchController : UISearchController!;
    var searchContainer : UISearchContainerViewController!;
    var searchBar: UISearchBar!{
        get{
            return self.searchController?.searchBar;
        }
    }
    var searchKeywordConroller : RSKeywordTableViewController!;
    var modelController : RSModelController {
        get{
            return RSModelController.shared;
        }
    }
    
    var emptyLabelView : UILabel?;
    var keywordView : UIView?;
    var hotKeywordController : RSHotKeywordTableViewController!;
    
    // MARK: to toggle Favorite Stock Item
    lazy var fetchedResultsController : LSFetchedResultsController<RSStoredStock> = {
        var moc : NSManagedObjectContext!;
        
        DispatchQueue.main.syncInMain {
            moc = RSModelController.shared.context;
        }
        
        let value = LSFetchedResultsController<RSStoredStock>("RSStoredStock", sortDescriptors: [NSSortDescriptor.init(key: "name", ascending: true)], moc: moc);
        value.fetch();
        return value;
    }();
    
    var stocksDisposeBag = DisposeBag();
    override func viewWillAppear(_ animated: Bool) {
        //self.tableView.reloadData();
    }
    
    var testText = PublishSubject<String>();
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil;
        self.tableView.delegate = nil;

        self.showKeywordView();
        /*RSStockController.shared.stocksRelay.asObservable()
         .asDriver(onErrorJustReturn: [])
         .map { $0.any ? UITableViewCellSeparatorStyle.singleLine : UITableViewCellSeparatorStyle.none }
        .drive(onNext: { (style) in
            self.tableView.separatorStyle = style;
            print("sets new table style[\(style)]");
        })
        .disposed(by: self.stocksDisposeBag);*/
        
        //self.searchBar.rx.text.bind
        RSSearchTableViewController.shared = self;
        self.fetchedResultsController.delegate = self;
        
        // Prepare view for the theme autocompletion
        self.refreshControl?.addTarget(self, action: #selector(refresh(refreshControl:)), for: .valueChanged);
        self.searchKeywordConroller = self.storyboard?.instantiateViewController(withIdentifier: "RSKeywordTableViewController") as? RSKeywordTableViewController;
        self.searchKeywordConroller.delegate = self;
        
        // MARK: Creates searchController with Keyword Table
        self.searchController = UISearchController(searchResultsController: self.searchKeywordConroller);
        self.searchController.searchResultsUpdater = self;
        self.searchController.hidesNavigationBarDuringPresentation = false;

        self.searchContainer = UISearchContainerViewController(searchController: self.searchController);

        //var searchBar = UISearchBar.init();
        self.navigationItem.titleView = self.searchBar;
        //self.tableView.tableHeaderView = self.searchController.searchBar;
        
        /*if #available(iOS 11.0, *){
            self.navigationItem.searchController = self.searchController;
            self.navigationItem.hidesSearchBarWhenScrolling = false;
        }else{
            self.tableView.tableHeaderView = self.searchBar;
        }*/
        
        self.searchController.dimsBackgroundDuringPresentation = false;
        searchBar.delegate = self;
        searchBar.showsCancelButton = false;
        searchBar.showsBookmarkButton = true;
        searchBar.placeholder = "주식 키워드";
        searchBar.showsScopeBar = false;
        searchBar.resignFirstResponder();
        self.searchController.dismiss(animated: true, completion: nil);

        //self.searchController.isActive = true;
        //self.searchBar.sizeToFit();
        
        /*self.updateKeywords { [unowned self] in
            guard self.keywords.count > 0 else{
                self.searchBar.showsScopeBar = false;
                return;
            }
        }*/
        self.definesPresentationContext = true;
        
        RSStockController.shared.requestStocks(withKeyword: "")
            .map({ (result) -> [RSStockItem] in
                switch result{
                case .Success(let items):
                    return items;
                case .Error(_):
                    self.openInternetError();
                    return [];
                }
            })
        .bindTableView(to: self.tableView, cellIdentifier: type(of: self).Cell_Id, cellType: RSSearchCell.self) { [weak self](row, stock, cell) in
            guard self != nil else{
                return;
            }
            
            let indexPath = IndexPath.init(row: row, section: 0);
            cell.iconImage.image = UIImage(named: "stock.png");
            cell.titleLabel?.text = stock.name;
            cell.showNewIndicator = Date().timeIntervalSince(stock.lastModified) < 60 * 60 * 24 * 3;
            cell.price = stock.price;
            cell.startPrice = stock.startPrice;
            cell.toggleOffsetAnimation(TimeInterval(row) * 0.3);
            // sets state of favorite
            cell.checkButton.addTarget(self!, action: #selector(self!.onCheckFav(button:)), for: .touchUpInside);
            
            let isFav = self!.modelController.isExistStocks(withName: stock.name) ? true : false;
            
            cell.checkButton.isSelected = isFav;
            print("check cell[\(indexPath.row.description)] name[\(stock.name)] button[\(cell.checkButton.description)] selected[\(isFav.description)]");
        }.disposed(by: self.stocksDisposeBag);
        
        RSStockController.shared.requestStocks(withKeyword: "")
            .map({ (result) -> [RSStockItem] in
                switch result{
                case .Success(let items):
                    return items;
                case .Error(_):
                    self.openInternetError();
                    return [];
                }
            })
            .map({ (stocks) -> UITableViewCellSeparatorStyle in
                return stocks.any ? .singleLine : .none
            })
        .asDriver(onErrorJustReturn: .none)
        .drive(onNext: { [unowned self](style) in
            if style == .singleLine{
                self.tableView.backgroundView = nil;
            }else{
                self.showKeywordView();
            }
            self.tableView.separatorStyle = style;
            self.refreshControl?.endRefreshing();
        })
        .disposed(by: self.stocksDisposeBag);
        
        RSStockController.shared.requestStocks(withKeyword: "")
            .filter { (result) -> Bool in
                return result.isError;
        }.asDriver(onErrorJustReturn: RSStockController.QueryResult<RSStockItem>.Success([]))
            .drive(onNext: { [unowned self](errorResult) in
                self.openInternetError();
        }).disposed(by: self.stocksDisposeBag);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !RSSearchTableViewController.startingKeyword.isEmpty{
            self.search(withKeyword: RSSearchTableViewController.startingKeyword);
        }
        
        guard ReviewManager.shared?.canShow ?? false else{
            return;
        }
        ReviewManager.shared?.show();
    }
    
    func showKeywordView(){
        if self.hotKeywordController == nil{
            self.hotKeywordController = self.storyboard?.instantiateViewController(withIdentifier: "RSHotKeywordTableViewController") as? RSHotKeywordTableViewController;
            self.hotKeywordController.selectedKeyword.subscribe(onNext: { (keyword) in
                self.search(withKeyword: keyword);
            }).disposed(by: self.stocksDisposeBag);
        }
        
        self.tableView.backgroundView = self.hotKeywordController.view;
        self.updateKeywords();
    }

    @objc func refresh(refreshControl : UIRefreshControl){
        self.search(withKeyword: self.searchBar?.text ?? "");
    }
    
    /**
     Clean Search Bar and Search Result
     */
    func clear(){
        self.searchBar.text = "";
        self.search(withKeyword: "");
        self.searchController.dismiss(animated: true, completion: nil);
        print("clear search result");
        self.tableView.reloadData();
    }

    func search(withKeyword keyword: String){
        self.searchBar?.text = keyword;

        self.searchController?.dismiss(animated: true, completion: nil);
        print("clear search result");
        // MARK: Gets stocks from sever by rest api
        RSStockController.shared.requestStocks(withKeyword: keyword);
        
        /*RSStockController.shared.requestStocks(withKeyword: keyword) { (items, error) in
            guard items != nil else{
                print("item request error. error[\(error?.description)]");
                DispatchQueue.main.syncInMain {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                }

                self.openSettingsOrCancel(title: "서버에 연결할 수 없습니다", msg: "인터넷에 연결하려면, 셀룰러 데이터를 켜거나 Wi-Fi를 사용하십시오.", titleForOK: "확인", titleForSettings: "설정");
                
                DispatchQueue.main.async{
                    self.refreshControl?.endRefreshing();
                }
                return;
            }
            
            DispatchQueue.main.sync {
                self.searchResults = items ?? [];
                DispatchQueue.main.syncInMain {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                }
                self.tableView.reloadData();
                self.refreshControl?.endRefreshing();
            }
        }*/
    }
    
    func updateKeywords(){
        //Gets hot keyword from server
        RSStockController.shared.requestKeywords();
    }
    
    // MARK: RSKeywordTableViewDelegate
    func keywordTable(controller: RSKeywordTableViewController, didSelectKeyword keyword: String) {
        self.searchBar.text = keyword;
        self.search(withKeyword: keyword);
    }
    
    // MARK: RSHotKeywordTableViewDelegatef
    func hotKeywordTable(controller: RSHotKeywordTableViewController, didSelectKeyword keyword: String) {
        self.searchBar.text = keyword;
        self.searchController.dismiss(animated: true, completion: nil);
        self.search(withKeyword: keyword);
    }
    
    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var cnt = 0;
        guard self.tableView === tableView else {
//            cnt = 3;
            return cnt;
        }
        cnt = self.searchResults.count
        
        if cnt > 0{
            self.tableView.separatorStyle = .singleLine;
        }else{
            self.tableView.separatorStyle = .none;
        }
        
        return cnt;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("get cell from table[\(tableView)]");
        var cell : RSSearchCell!;
        cell = tableView.dequeueReusableCell(withIdentifier: type(of: self).Cell_Id, for: indexPath) as? RSSearchCell;
        
        cell.iconImage.image = UIImage(named: "stock.png");
        cell.titleLabel?.text = self.searchResults[indexPath.row].name;
        
        cell.checkButton.addTarget(self, action: #selector(onCheckFav(button:)), for: .touchUpInside);
        
        let isFav = self.modelController.isExistStocks(withName: cell.titleLabel.text ?? "") ? true : false;
        
        cell.checkButton.isSelected = isFav;
        print("check cell[\(indexPath.row.description)] name[\(cell.titleLabel.text)] button[\(cell.checkButton.description)] selected[\(isFav)]");

        return cell;
    }*/
    
    @IBAction func onReview(_ button: UIBarButtonItem) {
        ReviewManager.shared?.show(true);
    }
    
    @IBAction func onCheckFav(button : UIButton){
        // MARK: Toggles Favorite for the Stock Item
        let cell = button.superview?.superview as! RSSearchCell;
        let value = !button.isSelected;

        //Checks if this stock item is already appended into favorites
        let stock = self.modelController.findStocks(withName: cell.titleLabel.text ?? "").first;
        if cell.checkButton.isSelected{
            guard stock != nil else{
                return;
            }
            
            //Remove stock item from favorites
            self.modelController.removeStock(stock: stock!);
        }else{
            guard stock == nil else{
                return;
            }
            
            //Appends stock item into favorites
            self.modelController.createStock(name: cell.titleLabel.text ?? "", keyword: self.searchBar.text ?? "");
        }
        
        cell.checkButton.isSelected = value;
        self.modelController.saveChanges();
    }

    /*override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cell = self.tableView.cellForRow(at: indexPath);
        var company = cell?.textLabel?.text ?? "";
        guard !company.isEmpty else{
            return;
        }
        
        var query = company.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "";
//        var urlString = "http://m.stock.naver.com/searchItem.nhn?where=nexearch&keyword=\(query)";
//        var url = URL.init(string: "http://m.stock.naver.com/searchItem.nhn?where=nexearch&keyword=\(query)");
        var url = URL(string: "http://search.naver.com/search.naver?query=\(query)");
//\(query)
        //%EB%8C%80%EC%84%B1%ED%8C%8C%EC%9D%B8%ED%85%8D
        print("open url[\(url)]");
        UIApplication.shared.open(url!, options: [:], completionHandler: nil);
    }*/
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: UISearchBarDelegate
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        print("onclick bookmark button. keyword[\(searchBar.text ?? "")]");
        self.search(withKeyword: "");
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("onclick cancel button. keyword[\(searchBar.text ?? "")]");
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        var keywords = searchBar.scopeButtonTitles ?? []
        let selectedKeyword = keywords[selectedScope];
        searchBar.text = selectedKeyword;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            self.search(withKeyword: searchText);
        }else{
            self.searchKeywordConroller.updateKeywords(keyword: searchText);
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.search(withKeyword: self.searchBar.text ?? "");
        if !RSModelController.shared.isExistKeywords(withName: self.searchBar.text ?? ""){
            RSModelController.shared.createKeyword(name: self.searchBar.text ?? "");
            RSModelController.shared.saveChanges();
        }
     
        searchBar.resignFirstResponder();
        self.searchController.dismiss(animated: true, completion: nil);
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationController?.isNavigationBarHidden = false;
        self.searchKeywordConroller.updateKeywords(keyword: searchBar.text ?? "");
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.navigationController?.isNavigationBarHidden = false;
    }
    
//    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
//        return searchBar.text?.isEmpty != true;
//    }
    
    // MARK: UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        print("update keyword history");
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let stock = anObject as? RSStoredStock else{
            return;
        }
        
        let searchCell = (self.tableView.visibleCells as? [RSSearchCell] ?? []).first { (cell) -> Bool in
            cell.titleLabel.text == stock.name
        };
        
        switch type{
            case .insert:
                searchCell?.checkButton.isSelected = true;
                break;
            case .delete:
                searchCell?.checkButton.isSelected = false;
                break;
            default:
                break;
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let internetView = segue.destination as? RSInternetViewController{
            //Configure view to show detail for the selected Stock item
            let cell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as? RSSearchCell;
            guard let company = cell?.titleLabel?.text else{
                return;
            }
            
            internetView.company = company;
            internetView.keyword = self.searchBar.text ?? "";
            internetView.hidesBottomBarWhenPushed = true;
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
