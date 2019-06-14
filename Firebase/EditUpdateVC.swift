//
//  EditUpdateVC.swift
//  TODOAPP
//
//  Created by icanstudioz on 14/06/19.
//  Copyright © 2019 icanstudioz.com. All rights reserved.
//

import UIKit
import Floaty
import Firebase

class EditUpdateVC: UIViewController {

    @IBOutlet weak var txttitle: UITextField!
    @IBOutlet weak var txtdate: UITextField!
    @IBOutlet weak var btn_submit: UIButton!
    @IBOutlet weak var txtdesc: UITextView!
    
    var dataList = [DataModel]()
    var refArtists: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //hide floaty button
         Floaty.global.hide()
        
        //set cornerradius of button
        btn_submit.layer.cornerRadius = 5.0
        btn_submit.clipsToBounds = true
        
        //set textview cornerradius and border
        txtdesc.layer.borderColor = UIColor.lightGray.cgColor
        txtdesc.layer.borderWidth = 0.5
        txtdesc.layer.cornerRadius = 5.0
        txtdesc.clipsToBounds = true
        
        //set placeholder of textview
        txtdesc.text = "Description"
        txtdesc.textColor = UIColor.lightGray
        
        //open datepicker from textfield
        txtdate.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingDidBegin)
        txtdate.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        
        //set navigation bar
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 44))
        view.addSubview(navBar)
        let navItem = UINavigationItem(title: "")
        let doneItem = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "back"), style:   .plain,  target: nil, action: #selector(btnback(_:)))
        navItem.leftBarButtonItem = doneItem
        navBar.setItems([navItem], animated: false)
        
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
                
            }
        })
        
        //set selected data when update
        if config.str_id != ""{
            txttitle.text = config.str_title
            txtdate.text = config.str_date
            txtdesc.text = config.str_description
        }
    }
    
    
    
    @IBAction func btnsubmit(_ sender: Any) {
        if config.str_id == ""{
        adddata()
        txttitle.text = ""
        txtdate.text = ""
        txtdesc.text = ""
        }
        else{
            updateArtist()
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "nav") as! UINavigationController
            self.present(newViewController, animated: false, completion: nil)
        }
    }
    
    //update data in firebase
    func updateArtist(){
        //creating data with the new given values
        let artist = ["id":config.str_id,
                      "title":txttitle.text! as String,
                      "date": txtdate.text! as String,
                      "description": txtdesc.text! as String
        ]
        
        //updating the data using the key of the artist
        refArtists.child(config.str_id).setValue(artist)
        let alert = UIAlertController(title: "", message: "data update successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
                                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                        let newViewController = storyBoard.instantiateViewController(withIdentifier: "nav") as! UINavigationController
                                        self.present(newViewController, animated: false, completion: nil)
                                        
                                        //handle ok action
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnback(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "nav") as! UINavigationController
        self.present(newViewController, animated: false, completion: nil)
    }
    
   //textfield delegate method
    @objc func textFieldDidChange(textField: UITextField) {
        //your code
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        textField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .editingDidBegin)
    }
   
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        txtdate.text = dateFormatter.string(from: sender.date)
    }
    
    
    ////insert in firebase database
    func adddata(){
        //generating a new key inside data node
        //and also getting the generated key
        let key = refArtists.childByAutoId().key
        
        //creating data with the given values
        let artist = ["id":key,
                      "title":txttitle.text! as String,
                      "date": txtdate.text! as String,
                      "description": txtdesc.text! as String
        ]
        
        //adding the data inside the generated unique key
        refArtists.child(key!).setValue(artist)
        
        let alert = UIAlertController(title: "", message: "detail saved successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
                                        
                          //handle ok action
                                        
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
