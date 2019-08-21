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
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    var allStates = USFlags.allFlags
    var dbRef: DatabaseReference!
    var storageRef: StorageReference!
    var flagModel = [FlagsModel]()
    
    var existingState: Bool!
    
    var fetchResultsController : NSFetchedResultsController<NationalPark>!
    
    var dataController: DataController! {
        var object = UIApplication.shared.delegate
        var appDelegate = object as! AppDelegate
        return appDelegate.dataController
    }
    
    
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
        //MARK CHECK TO SEE IF STATE EXISTS
        self.checkForExistingState(abbrName: flags.abbrName)
        
        
        parkDetailViewController.parkDoesNotExist = self.existingState
        
        parkDetailViewController.abbrName = flags.abbrName
        self.navigationController!.pushViewController(parkDetailViewController, animated: true)
        
        
    }

}

extension ViewController {
    
    
    fileprivate func checkForExistingState(abbrName: String) {
        //MARK CHECK TO SEE IF IT EXIST IN CORE DATA
        //MARK SAVE TO CORE DATA
        
        let fetchRequest:NSFetchRequest<NationalPark> = NationalPark.fetchRequest()
        
        
        let predicate = NSPredicate(format: "stateAbbrName == %@", abbrName)
        
        fetchRequest.predicate = predicate
        
        fetchRequest.fetchLimit = 1
        
        let sortDescriptor = NSSortDescriptor(key: "stateAbbrName", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        
        
        do {
            try fetchResultsController.performFetch()
        } catch  let error {
            debugPrint("DetatilViewController: catchStatement \(error.localizedDescription)")
            fatalError(error.localizedDescription)
        }
        
        
        do {
            
            let totalCount = try fetchResultsController.managedObjectContext.count(for: fetchRequest)
            
            if totalCount > 0 {
                print("total count \(totalCount)")
                debugPrint("Existing State is true")
                self.existingState = true
            } else {
                debugPrint("Existing State is false")
                existingState = false
                self.existingState = false
            }
            
        } catch let error {
            print("setupFetchedResultsControllerAndGetPhotos: \(error.localizedDescription)")
        }
    }
    
}

