//
//  EditVC.swift
//  TODOAPP
//
//  Created by icanstudioz on 13/06/19.
//  Copyright © 2019 icanstudioz.com. All rights reserved.
//

import UIKit
import SQLite3
import Floaty
import Firebase

class EditVC: UIViewController {
    var db: OpaquePointer?
    var Detaillist = [Detail]()
    var refArtists: DatabaseReference!
    
    @IBOutlet weak var txttitle: UITextField!
    @IBOutlet weak var txtdate: UITextField!
    @IBOutlet weak var txtdescription: UITextField!
    @IBOutlet weak var btn_submit: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //getting a reference to the node artists
        refArtists = Database.database().reference().child("data");
        
        btn_submit.layer.cornerRadius = 5.0
        btn_submit.clipsToBounds = true

      
        Floaty.global.hide()
        
        txtdate.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingDidBegin)
        txtdate.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 44))
        view.addSubview(navBar)
        
        let navItem = UINavigationItem(title: "")
        let doneItem = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "back"), style:   .plain,  target: nil, action: #selector(btnback(_:)))
        navItem.leftBarButtonItem = doneItem
        
        navBar.setItems([navItem], animated: false)
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Tododatabase.sqlite")
        
        print(fileURL)
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Detail (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, date TEXT, description TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        readValues()
        
        if config.str_id != ""{
           
           readValues1()
        }
    }
    
    ///function insert in firebase
    func adddata(){
        //generating a new key inside artists node
        //and also getting the generated key
       //
        
        
        
        let key = refArtists.childByAutoId().key
        
        //creating artist with the given values
        let artist = ["title":txttitle.text! as String,
                      "date": txtdate.text! as String,
                      "description": txtdescription.text! as String
        ]
        
        //adding the artist inside the generated unique key
       
        refArtists.child(key!).setValue(artist)
        
        //displaying message
       // labelMessage.text = "Artist Added"
    }
 
    @IBAction func btnback(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "nav") as! UINavigationController
        self.present(newViewController, animated: false, completion: nil)
    }
    @IBAction func btnsubmit(_ sender: Any) {
        print(config.str_id)
        if config.str_id == ""{
        
            adddata()
        let title = txttitle.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let date = txtdate.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = txtdescription.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(title?.isEmpty)!{
            txttitle.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        if(date?.isEmpty)!{
            txtdate.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        var stmt: OpaquePointer?
        let SQLITE_TRANSIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)
        
        let queryString = "INSERT INTO Detail (title, date, description) VALUES (?,?,?)"
        print(queryString)
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 1, title, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding title: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 2, date, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding date: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 3, description, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding description: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        //sqlite3_finalize(stmt)
        
        txttitle.text = ""
        txtdate.text = ""
        txtdescription.text = ""
        
       readValues()
        
        print("detail saved successfully")
            
            
            let alert = UIAlertController(title: "", message: "detail saved successfully", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: UIAlertAction.Style.default,
                                          handler: {(_: UIAlertAction!) in
                                            
                                            
                                            
            }))
           
            self.present(alert, animated: true, completion: nil)
        }
        else{
           
            updateValues()
        }
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
        func readValues1(){
            Detaillist.removeAll()
            
            let queryString = "SELECT * FROM Detail WHERE id = '\(config.str_id)'"
            
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
                
//                let Detail: Detail
//                let idint = Int(config.str_id)
//                Detail = self.Detaillist[idint!]
                txttitle.text = title
                txtdate.text = date
                txtdescription.text = description
                
                // Detaillist.append(Hero(id: Int(id), name: String(describing: name), powerRanking: Int(powerrank)))
//                Detaillist.append(Detail(id: String(describing: id), title: String(describing: title), date:String(describing: date), description: String(describing: description)))
            }
    }
    
    
    func updateValues(){
        // Detaillist.removeAll()
        
        let queryString = "UPDATE Detail SET title = '\(String(describing:  txttitle.text!))', date = '\(String(describing: txtdate.text!))', description = '\(String(describing: txtdescription.text!))' WHERE id = '\(config.str_id)' "
        print(queryString)
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing update: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) == SQLITE_DONE {
            print("Successfully update row.")
            let alert = UIAlertController(title: "", message: "data update successfully", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: UIAlertAction.Style.default,
                                          handler: {(_: UIAlertAction!) in
                                            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                            let newViewController = storyBoard.instantiateViewController(withIdentifier: "nav") as! UINavigationController
                                            self.present(newViewController, animated: false, completion: nil)
                                            
                                            
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            print("Could not update row.")
        }
        
        
    }
   @objc func textFieldDidChange(textField: UITextField) {
        //your code
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        textField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .editingDidBegin)
    }
    
//    @IBAction func dp(_ sender: UITextField) {
//        let datePickerView = UIDatePicker()
//        datePickerView.datePickerMode = .date
//        sender.inputView = datePickerView
//        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
//        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .editingDidBegin)
//    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        txtdate.text = dateFormatter.string(from: sender.date)
    }
    
}



