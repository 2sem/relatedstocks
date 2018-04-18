//
//  RSKeywordTableViewController.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 24..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit

protocol RSKeywordTableViewDelegate {
    func keywordTable(controller : RSKeywordTableViewController, didSelectKeyword keyword: String);
}

class RSKeywordTableViewController: UITableViewController {
    static let RSKeywordCell = "RSSearchCell";

//    var keyword = "";
    var keywords : [RSStoredKeyword] = [];
    
    var delegate : RSKeywordTableViewDelegate?;
    
    var modelController : RSModelController {
        get{
            return RSModelController.Default;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.refreshControl?.addTarget(self, action: #selector(updateKeywords(refreshControl:)), for: .valueChanged);
//        self.view.backgroundColor = UIColor.red;
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: RSKeywordTableViewController.RSKeywordCell);
    }
    
    func updateKeywords(keyword: String){
//        refreshControl.isRefreshing = true;
        self.keywords = RSModelController.Default.findKeywords(withName: keyword);
        self.tableView.reloadData();
        
        return;
        RSStockController.Default.requestKeywords { (keywords, error) in
            guard error == nil else{
                return;
            }
            
//            self.keywords = keywords!;
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
    
    func onDeleteKeyword(button : UIButton){
        let cell = button.superview as! UITableViewCell;
        //        print("check fav cell -> \(cell)");
        var value = !button.isSelected;
        
        var keyword = self.keywords.filter { (k) -> Bool in
            return k.name == cell.textLabel?.text;
        }.first;
        
        guard keyword != nil else{
            return;
        }
        
        self.modelController.removeKeyword(keyword: keyword!);
        var indexPath = self.tableView.indexPath(for: cell);
        if indexPath != nil{
            var index = self.keywords.index(of: keyword!);
            self.keywords.remove(at: index!);

            self.tableView.deleteRows(at: [indexPath!], with: .automatic);
        }
        
        self.modelController.saveChanges();
        //        var stock : RSStoredStock?;
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.keywords.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!;

        cell = tableView.dequeueReusableCell(withIdentifier: RSKeywordTableViewController.RSKeywordCell, for: indexPath);
        
        //        var cell = UITableViewCell();
        cell.textLabel?.text = self.keywords[indexPath.row].name;
        print("print keyword cell. keyword[\(cell.textLabel?.text)]");
        var pointSize = CGFloat(20.0);
        cell.textLabel?.font = cell.textLabel?.font.withSize(pointSize);
        
        var clearButton : UIButton?;
        if cell.accessoryView == nil{
            clearButton = UIButton(frame: CGRect.init(origin: CGPoint.zero, size: CGSize(width: 40, height: 40)));
            clearButton?.setTitle("X", for: .normal);
    //        clearButton.titleLabel?.textColor = UIColor.black;
    //        clearButton.setTitleColor(UIColor.black, for: .normal);
            clearButton?.backgroundColor = UIColor.lightGray;
            clearButton?.layer.cornerRadius = 10;
    //        pointSize = CGFloat(10.0);
    //        clearButton.titleLabel?.font = cell.textLabel?.font.withSize(pointSize);
            
            cell.accessoryView = clearButton;
            
        }else{
            clearButton = cell.accessoryView as? UIButton;
        }
        
        clearButton?.addTarget(self, action: #selector(onDeleteKeyword(button:)), for: .touchUpInside);
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var keyword = self.keywords[indexPath.row].name ?? "";
        self.delegate?.keywordTable(controller: self, didSelectKeyword: keyword);
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
