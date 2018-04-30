//
//  RSHotKeywordTableViewController.swift
//  relatedstocks
//
//  Created by 영준 이 on 2017. 2. 14..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit

protocol RSHotKeywordTableViewDelegate {
    func hotKeywordTable(controller : RSHotKeywordTableViewController, didSelectKeyword keyword: String);
}

class RSHotKeywordTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    static let RSKeywordCell = "RSKeywordCell";
    
    var keywords : [RSStockKeyword] = [];
    
    var delegate : RSHotKeywordTableViewDelegate?;
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        //self.updateKeywords();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.updateKeywords();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateKeywords();
//        self.refreshControl?.addTarget(self, action: #selector(updateKeywords(refreshControl:)), for: .valueChanged);
        //        self.view.backgroundColor = UIColor.red;
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: RSHotKeywordTableViewController.RSKeywordCell);
    }
    
    func updateKeywords(){
        //        refreshControl.isRefreshing = true;
        RSStockController.shared.requestKeywords { (keywords, error) in
            guard error == nil else{
                return;
            }
            
            self.keywords = keywords!;
            DispatchQueue.main.async {
                self.tableView.reloadData();
//                refreshControl.endRefreshing();
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.keywords.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!;
        
        cell = tableView.dequeueReusableCell(withIdentifier: RSHotKeywordTableViewController.RSKeywordCell, for: indexPath);
        
        //        var cell = UITableViewCell();
        cell.textLabel?.text = self.keywords[indexPath.row].name;
        print("print keyword cell. keyword[\(cell.textLabel?.text)]");
        var pointSize = CGFloat(17.0);
        cell.textLabel?.font = cell.textLabel?.font.withSize(pointSize);
        cell.textLabel?.textColor = UIColor.blue;
        cell.textLabel?.highlightedTextColor = UIColor.gray;
        cell.textLabel?.textAlignment = .center;
        cell.selectionStyle = .none;
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var keyword = self.keywords[indexPath.row].name ?? "";
        self.delegate?.hotKeywordTable(controller: self, didSelectKeyword: keyword);
    }
    
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
