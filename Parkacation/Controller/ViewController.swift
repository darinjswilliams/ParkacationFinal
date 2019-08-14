//
//  ViewController.swift
//  Parkacation
//
//  Created by Darin Williams on 7/28/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    var allStates = USFlags.allFlags
    var dbRef: DatabaseReference!
    var storageRef: StorageReference!
    var flagModel = [FlagsModel]()
    
    
    var imageReference: StorageReference {
        return storageRef.child("us_flags")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        configureDatabase()
        configureStorage()
        loadFromDatabase()
    }
    
    
    fileprivate func configureDatabase() {
        //MARK CALL FLAG API
        // Do any additional setup after loading the view.
        dbRef = Database.database().reference(withPath: "data")
        
    }
    
    fileprivate func configureStorage() {
        storageRef = Storage.storage().reference()
        let myStorage = storageRef.child("us_flags")
        
    }
    
    //Mark From Firebase
    func loadFromDatabase(){
        LoadingViewActivity.show(tableView, loadingText: "Loading")
        dbRef.observe(.value, with: {snapshot in
            
            //MARK Iterate over items FROM DATABASE
            var dataModel:[FlagsModel] = []
            for item in snapshot.children {
                
                if let snapshot = item as? DataSnapshot,
                    let flgItem =  FlagsModel(snapshot: snapshot){
                    dataModel.append(flgItem)
                }
               debugPrint("datamodel count.. \(dataModel.count)")
                
             }
            
            //MARK LOAD DATA INTO ARRAY AND RELOAD TABLE
            self.flagModel = dataModel
            self.tableView.reloadData()
            
        })
        
        LoadingViewActivity.hide()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.flagModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //StateCell
        
       let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell")
       let usFlags = self.flagModel[(indexPath as NSIndexPath).row]
        

    
        if let imageURL = usFlags.flagImage as? String {
            if imageURL.hasPrefix("gs://") {
                Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX) {(data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    DispatchQueue.main.async {
                        cell!.imageView?.image = UIImage.init(data: data!)
                        cell!.setNeedsLayout()
                    }
                }
            } else if let URL = URL(string: imageURL), let data = try? Data(contentsOf: URL) {
                cell?.imageView?.image = UIImage.init(data: data)
            }
        }
            
       cell?.textLabel?.text = usFlags.abbrName
        
        if let detailText = cell?.detailTextLabel {
             detailText.text = usFlags.fullName
        }
        
        return cell!
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let parkDetailViewController = self.storyboard!.instantiateViewController(withIdentifier: "ParkDetailsViewController") as! ParkDetailViewController
        
    
           let flags = self.flagModel[(indexPath as NSIndexPath).row]
        
         debugPrint("ViewController: Selected Item \(flags.fullName)")
        
        parkDetailViewController.abbrName = flags.abbrName
        self.navigationController!.pushViewController(parkDetailViewController, animated: true)
        
        
    }

}

