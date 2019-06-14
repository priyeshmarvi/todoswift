//
//  ViewController.swift
//  TODOAPP
//
//  Created by icanstudioz on 13/06/19.
//  Copyright © 2019 icanstudioz.com. All rights reserved.
//

import UIKit
import SQLite3
import Floaty

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
     
    @IBOutlet weak var DetailTableVC: UITableView!
    @IBOutlet weak var btnfloaty: UIButton!
    var Detaillist = [Detail]()
    var db: OpaquePointer?
    override func viewDidLoad() {
        super.viewDidLoad()
    
        DetailTableVC.backgroundView = UIImageView(image: UIImage(named: "theme.jpeg"))
        config.str_id = ""
       // Floaty.global.button.addItem(title: "Hello, World!")
       Floaty.global.show()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        Floaty.global.button.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view, typically from a nib.
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Tododatabase.sqlite")
        
        print(fileURL)
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
//        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Detail (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, date TEXT, description TEXT)", nil, nil, nil) != SQLITE_OK {
//            let errmsg = String(cString: sqlite3_errmsg(db)!)
//            print("error creating table: \(errmsg)")
//        }
      readValues()
    }
    @objc func handleSingleTap(recognizer: UITapGestureRecognizer) {
        // Do stuff here...
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "EditVC") as! EditVC
        self.present(newViewController, animated: false, completion: nil)
    }
   
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Detaillist.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : DisplayCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DisplayCell
       // let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.backgroundColor = UIColor.clear
        let Detail: Detail
        Detail = Detaillist[indexPath.row]
        cell.lbl_title?.text = Detail.title
        cell.lbl_date?.text = Detail.date
        cell.lbl_description?.text = Detail.description
        
       

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
//        let more = UITableViewRowAction(style: .normal, title: "More") { action, index in
//            print("more button tapped")
//        }
      //  more.backgroundColor = .lightGray
        
       
        
        let Edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "EditVC") as! EditVC
            let Detail: Detail
            Detail = self.Detaillist[index.row]
            let index1 = Detail.id
            config.str_id = index1 ?? ""
            self.present(newViewController, animated: false, completion: nil)
            print("Edit button tapped")
        }
        Edit.backgroundColor = .black//UIColor(red:0.80, green:0.40, blue:1.00, alpha:1.0)//.green
        
        let Delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let Detail: Detail
            Detail = self.Detaillist[index.row]
            let index1 = Detail.id
            self.deleteValues(strid: index1!)
            print("Delete button tapped")
        }
        Delete.backgroundColor = .red
        
        return [Delete, Edit]
    }
    
    func readValues(){
        Detaillist.removeAll()
        
        let queryString = "SELECT * FROM Detail"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = String(cString: sqlite3_column_text(stmt, 0))//sqlite3_column_int(stmt, 0)
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let date = String(cString: sqlite3_column_text(stmt, 2))
            let description = String(cString: sqlite3_column_text(stmt, 3))
            
            // Detaillist.append(Hero(id: Int(id), name: String(describing: name), powerRanking: Int(powerrank)))
            Detaillist.append(Detail(id: String(describing: id), title: String(describing: title), date:String(describing: date), description: String(describing: description)))
        }
    
    }
    
    
    func deleteValues(strid: String){
       // Detaillist.removeAll()
        
        let queryString = "DELETE FROM Detail WHERE id = " + strid
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing delete: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) == SQLITE_DONE {
            print("Successfully deleted row.")
            let alert = UIAlertController(title: "", message: "data delete successfully", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: UIAlertAction.Style.default,
                                          handler: {(_: UIAlertAction!) in
                                            
                                            
                                            
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            print("Could not delete row.")
        }
        readValues()
        DetailTableVC.reloadData()
    
    }
    
    
    
  
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }


}

