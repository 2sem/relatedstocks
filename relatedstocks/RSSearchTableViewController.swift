//
//  RSSearchTableViewController.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 16..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit

class RSSearchTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, RSKeywordTableViewDelegate, RSHotKeywordTableViewDelegate {

    static let RSSearchCell = "RSSearchCell";
    
    var searchResults : [RSStockItem] = [];//[RSStockItem("우리들제약"), RSStockItem("바른손"), RSStockItem("위노바"), RSStockItem("서희건설"), RSStockItem("에이연희"), RSStockItem("궁일신동")];
    var keywords : [RSStockKeyword] = []{
        didSet{
//            var strs : [String] = [];
//            for k in keywords{
//                strs.append(k.name ?? "");
//            }
            
            /*DispatchQueue.main.async {
                self.searchKeywordConroller.keywords = self.keywords;
//                self.searchBar.scopeButtonTitles = strs;
            }*/
        }
    }
    
//    @IBOutlet weak var searchBar: UISearchBar!
    private(set) static var shared : RSSearchTableViewController?;
    static var startingKeyword = ""{
        didSet{
            RSSearchTableViewController.shared?.navigationController?.popViewController(animated: true);
            RSSearchTableViewController.shared?.search(withKeyword: startingKeyword);
            RSSearchTableViewController.shared?.searchBar.text = startingKeyword;
        }
    }
    var searchController : UISearchController!;
    var searchContainer : UISearchContainerViewController!;
    var searchBar: UISearchBar{
        get{
            return self.searchController.searchBar;
        }
    }
    var searchKeywordConroller : RSKeywordTableViewController!;
    var modelController : RSModelController {
        get{
            return RSModelController.Default;
        }
    }
    
    var emptyLabelView : UILabel?;
    var keywordView : UIView?;
    var hotKeywordController : RSHotKeywordTableViewController!;
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RSSearchTableViewController.shared = self;
        self.showKeywordView();
        
        self.refreshControl?.addTarget(self, action: #selector(refresh(refreshControl:)), for: .valueChanged);
        self.searchKeywordConroller = self.storyboard?.instantiateViewController(withIdentifier: "RSKeywordTableViewController") as? RSKeywordTableViewController;
        self.searchKeywordConroller.delegate = self;
        
        self.searchController = UISearchController(searchResultsController: self.searchKeywordConroller);
        self.searchContainer = UISearchContainerViewController(searchController: self.searchController);
        
        self.searchController.searchResultsUpdater = self;
        self.searchController.dimsBackgroundDuringPresentation = false;
//        self.tableView.tableHeaderView = self.searchController.searchBar;
        self.navigationItem.titleView = self.searchController.searchBar;
        self.searchController.hidesNavigationBarDuringPresentation = false;
//        self.searchBar.delegate = self;
        
        self.searchBar.delegate = self;
//        self.searchBar.showsScopeBar = true;
//        self.searchBar.scopeButtonTitles = ["문재인", "안철수", "이재명", "더민주", "정의당", "안희정"];
//        self.searchBar.showsBookmarkButton = true;
        self.searchBar.showsCancelButton = false;
        self.searchBar.placeholder = "주식 키워드";
        
        //self.searchBar.showsSearchResultsButton = true;
//        self.searchBar.selectedScopeButtonIndex = 0;
        
        self.searchBar.showsScopeBar = false;
        self.updateKeywords {
//            if self.searchBar.selectedScopeButtonIndex == 0{
            guard self.keywords.count > 0 else{
                self.searchBar.showsScopeBar = false;
                return;
            }

//            self.searchBar.showsScopeBar = true;
            //auto select
            /*DispatchQueue.main.async {
                self.searchBar.text = self.keywords[0].name;
                self.search(withKeyword: self.searchBar.text ?? "");
                self.searchBar.becomeFirstResponder();
//                self.searchBar(self.searchBar, selectedScopeButtonIndexDidChange: 0);
            }*/
            
//            }
        }
        
//        self.searchBar.showsSearchResultsButton = true;
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.definesPresentationContext = true;
        
//        print("register into table[\(self.tableView)]");
//        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: RSSearchTableViewController.RSSearchCell);
        return;
        var nav = UINavigationController(rootViewController: self.searchContainer);
        self.present(nav, animated: true, completion: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !RSSearchTableViewController.startingKeyword.isEmpty{
            //self.searchBar.text = RSSearchTableViewController.startingKeyword;
            self.search(withKeyword: RSSearchTableViewController.startingKeyword);
            //self.searchBar(self.searchBar, textDidChange: self.searchBar.text!);
        }
        
        guard ReviewManager.shared?.canShow ?? false else{
            //self.fullAd?.show();
            return;
        }
        ReviewManager.shared?.show();
    }
    
    func showKeywordView(){
        if self.hotKeywordController == nil{
            self.hotKeywordController = self.storyboard?.instantiateViewController(withIdentifier: "RSHotKeywordTableViewController") as? RSHotKeywordTableViewController;
        }
        
        self.hotKeywordController.delegate = self;
        self.tableView.backgroundView = self.hotKeywordController.view;
    }
    
    func showEmptyView(){
        if self.emptyLabelView == nil{
            self.emptyLabelView = UILabel();
            self.emptyLabelView?.sizeToFit();
            self.emptyLabelView?.text = "no results T.T";
            self.tableView.backgroundView = self.emptyLabelView;
            self.emptyLabelView?.textAlignment = .center;
            self.emptyLabelView?.sizeToFit();
        }
        
        self.tableView.backgroundView = self.emptyLabelView;
    }

    func refresh(refreshControl : UIRefreshControl){
        self.search(withKeyword: self.searchBar.text ?? "");
    }
    
    func clear(){
        self.searchBar.text = "";
        //self.search(withKeyword: "");
        self.searchResults = [];
        self.searchController.dismiss(animated: true, completion: nil);
        self.tableView.reloadData();
    }
    
    func search(withKeyword keyword: String){
//        self.searchController.isActive = false;
        self.searchBar.text = keyword;

        self.searchController.dismiss(animated: true, completion: nil);
        DispatchQueue.main.syncInMain {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        }
        RSStockController.Default.requestStocks(withKeyword: keyword) { (items, error) in
            guard items != nil else{
                print("item request error. error[\(error)]");
                DispatchQueue.main.syncInMain {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                }
//                self.showCellularAlert(title: "Internet Unavailable");
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
        }
    }
    
    func updateKeywords(completion: (() -> Void)?){
        RSStockController.Default.requestKeywords { (keywords, error) in
            DispatchQueue.main.syncInMain {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false;
            }
            guard error == nil else{
                return;
            }
            
            self.keywords = keywords ?? [];
            completion?();
        }
    }
    
    // MARK: RSKeywordTableViewDelegate
    func keywordTable(controller: RSKeywordTableViewController, didSelectKeyword keyword: String) {
        self.searchBar.text = keyword;
        self.search(withKeyword: keyword);
    }
    
    // MARK: RSHotKeywordTableViewDelegatef
    func hotKeywordTable(controller: RSHotKeywordTableViewController, didSelectKeyword keyword: String) {
        self.searchBar.text = keyword;
        self.search(withKeyword: keyword);
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
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
//        guard self.tableView === tableView else {
//            cell = UITableViewCell(style: .default, reuseIdentifier: nil);
//            cell.textLabel?.text = "Recommend Keyword \(indexPath.row)";
//            print("cell for recommend keyword. index[\(indexPath.row)]");
//            return cell;
//        }
        cell = tableView.dequeueReusableCell(withIdentifier: RSSearchTableViewController.RSSearchCell, for: indexPath) as? RSSearchCell;
        
//        var cell = UITableViewCell();
//        cell.textLabel?.text = self.searchResults[indexPath.row].name;
        cell.iconImage.image = UIImage(named: "stock.png");
        cell.titleLabel?.text = self.searchResults[indexPath.row].name;
        
        
//        var pointSize = CGFloat(20.0);
//        cell.titleLabel?.font = cell.titleLabel?.font.withSize(pointSize);

//        if indexPath.row % 2 == 0{
//            cell.checkButton.isSelected = true;
//        }
        
        
        cell.checkButton.addTarget(self, action: #selector(onCheckFav(button:)), for: .touchUpInside);
        
        var isFav = self.modelController.isExistStocks(withName: cell.titleLabel.text ?? "") ? true : false;
        
        cell.checkButton.isSelected = isFav;
        print("check cell[\(indexPath.row)] name[\(cell.titleLabel.text)] button[\(cell.checkButton)] selected[\(isFav)]");
//        DispatchQueue.main.sync{
//            cell.checkButton.isSelected = isFav;
//            cell.checkButton.isSelected = self.modelController.isExistStocks(withName: cell.titleLabel.text ?? "");
//        }
//        cell.layoutIfNeeded();
        // Configure the cell...

        return cell;
    }
    
    func onCheckFav(button : UIButton){
        let cell = button.superview?.superview as! RSSearchCell;
//        print("check fav cell -> \(cell)");
        var value = !button.isSelected;

        var stock = self.modelController.findStocks(withName: cell.titleLabel.text ?? "").first;
        if cell.checkButton.isSelected{
            
            guard stock != nil else{
                return;
            }
            
            self.modelController.removeStock(stock: stock!);
        }else{
            guard stock == nil else{
                return;
            }
            
            self.modelController.createStock(name: cell.titleLabel.text ?? "", keyword: self.searchBar.text ?? "");
        }
        
        cell.checkButton.isSelected = value;
        self.modelController.saveChanges();
//        var stock : RSStoredStock?;
        
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
        print("onclick bookmark button. keyword[\(searchBar.text)]");
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("onclick cancel button. keyword[\(searchBar.text)]");
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        var keywords = searchBar.scopeButtonTitles ?? []
        let selectedKeyword = keywords[selectedScope] ?? searchBar.text;
        searchBar.text = selectedKeyword;
        
        self.search(withKeyword: selectedKeyword!);
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            self.searchResults = [];
            self.tableView.reloadData();
            self.hotKeywordController.updateKeywords();
        }else{
            self.searchKeywordConroller.updateKeywords(keyword: searchText);
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.search(withKeyword: self.searchBar.text ?? "");
        if !RSModelController.Default.isExistKeywords(withName: self.searchBar.text ?? ""){
            RSModelController.Default.createKeyword(name: self.searchBar.text ?? "");
            RSModelController.Default.saveChanges();
        }
        
//        searchBar.endEditing(true);
        searchBar.resignFirstResponder();
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        self.searchController.isActive = true;
        self.searchKeywordConroller.updateKeywords(keyword: searchBar.text ?? "");
    }
    
//    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
//        return searchBar.text?.isEmpty != true;
//    }
    
    // MARK: UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        print("update keyword history");
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let internetView = segue.destination as? RSInternetViewController{
            var cell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as? RSSearchCell;
            var company = cell?.titleLabel?.text;
            internetView.company = company!;
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
