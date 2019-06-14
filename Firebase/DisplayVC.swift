//
//  DisplayVC.swift
//  TODOAPP
//
//  Created by icanstudioz on 14/06/19.
//  Copyright © 2019 icanstudioz.com. All rights reserved.
//

import UIKit
import Floaty
import Firebase

class DisplayVC: UIViewController , UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var DetailTableVC: UITableView!
   
     var dataList = [DataModel]()
     var refArtists: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config.str_id = ""
        
        //show floaty button
        Floaty.global.show()
      
        //click event of floaty button
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        Floaty.global.button.addGestureRecognizer(tapGesture)
        
         //getting a reference to the node data
        refArtists = Database.database().reference().child("data");
        
        //observing the data changes
        refArtists.observe(DataEventType.value, with: { (snapshot) in
            
            //if the reference have some values
            if snapshot.childrenCount > 0 {
                
                //clearing the list
                self.dataList.removeAll()
                
                //iterating through all the values
                for data in snapshot.children.allObjects as! [DataSnapshot] {
                    //getting values
                    let dataObject = data.value as? [String: AnyObject]
                    let Id  = dataObject?["id"]
                    let title  = dataObject?["title"]
                    let date  = dataObject?["date"]
                    let description = dataObject?["description"]
                    
                    //creating data object with model and fetched values
                    let data = DataModel(id: Id as! String?,title: title as! String?, date: date as! String?, description: description as! String?)
                    //appending it to list
                    self.dataList.append(data)
                }
                
                //reloading the tableview
                self.DetailTableVC.reloadData()
            }
        })
    }
    
    
    @objc func handleSingleTap(recognizer: UITapGestureRecognizer) {
        // Do stuff here...
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "EditUpdateVC") as! EditUpdateVC
        self.present(newViewController, animated: false, completion: nil)
    }
    
    
    //Tableview Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : DisplayCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DisplayCell
     
        //the data object
        let data: DataModel
        
        //getting the data of selected position
        data = dataList[indexPath.row]
        
        //adding values to labels
        cell.lbl_title.text = data.title
        cell.lbl_date.text = data.date
        cell.lbl_description.text = data.description
        
        
        return cell
    }
    
    
    //create edit and delete button when tableview cell swip
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
     
        let Edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "EditUpdateVC") as! EditUpdateVC
            let DataModel: DataModel
            DataModel = self.dataList[index.row]
            let index1 = DataModel.id
            config.str_id = index1 ?? ""
            config.str_title = DataModel.title!
            config.str_date = DataModel.date!
            config.str_description = DataModel.description!
           self.present(newViewController, animated: false, completion: nil)
            print("Edit button tapped")
        }
        Edit.backgroundColor = .black
        
        let Delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let DataModel: DataModel
            DataModel = self.dataList[index.row]
            let index1 = DataModel.id
            config.str_id = index1 ?? ""
            self.deletedata(id: config.str_id)
            print("Delete button tapped")
        }
        Delete.backgroundColor = .red
        
        return [Delete, Edit]
    }

    
    func deletedata(id:String){
        refArtists.child(id).setValue(nil)
        let alert = UIAlertController(title: "", message: "data delete successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
                                        
                                  //handle OK action here
                                        
        }))
        
        self.present(alert, animated: true, completion: nil)
       
    }
}
