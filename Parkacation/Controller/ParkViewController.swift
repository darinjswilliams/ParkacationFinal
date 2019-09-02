//
//  ParkViewController.swift
//  Parkacation
//
//  Created by Darin Williams on 7/31/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreData
import Kingfisher

class ParkViewController: UIViewController,  UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate
{
    
    
var allStates = USFlags.allFlags
    
@IBOutlet weak var collectionView: UICollectionView!
    
var dbRef: DatabaseReference!
    
var storageRef: StorageReference!
    
var flagModel = [FlagsModel]()
    
var parkFilterByCoordinates: [Parks] = [Parks]()
    
var fetchResultsController : NSFetchedResultsController<NationalPark>!

var nationalParks : [NationalPark] = []
    
var nationalPark : NationalPark!
    
var existingState: Bool!
    
var abbrName: String?
    
var stateUS: State!


//lets set up dependencty injections
    
    var dataController: DataController! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.dataController
    }
    

    
    
override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    //MARK CORE DATA RELATIONSHIP
    
    navigationItem.title = "We're Logged in"
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handleSignOut))
    
    self.stateUS = State(context: dataController.viewContext)
    dbRef = DatabaseConfig.shared.configureDatabase()
    storageRef =  DatabaseConfig.shared.configureStorage()
 
    
}

    
  fileprivate func userIsLoggedIn() -> Bool {
        
        return  UserDefaults.standard.bool(forKey: "userIsLoggedIn")
    }
    
    
    
//    @objc func handleSignOut(){
//
//        UserDefaults.standard.set(false, forKey: "userIsLoggedIn")
//        UserDefaults.standard.synchronize()
//
//        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//
//        let lgView  = mainStoryBoard.instantiateViewController(withIdentifier:"LoginViewController") as! LoginViewController
//
//
//        present(lgView, animated: false, completion: nil)
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
      
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadFromDatabase()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchResultsController = nil
    }
    

func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
   return self.flagModel.count
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let sfCell = collectionView.dequeueReusableCell(withReuseIdentifier: "StateFlagCollectionViewCell", for: indexPath) as! StateFlagCollectionViewCell
    
    // Configure the cell
    let usFlags = self.flagModel[(indexPath as NSIndexPath).row]
    
 
    if let imageURL = usFlags.flagImage as? String {
        if imageURL.hasPrefix("gs://") {
            Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX) {(data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
         
                DispatchQueue.main.async {
                    //USE KINGFISHER
                    sfCell.photoImage.image = UIImage.init(data: data!)
                    sfCell.setNeedsLayout()
                }
            }
        } else if let URL = URL(string: imageURL), let data = try? Data(contentsOf: URL) {
            sfCell.photoImage.image = UIImage.init(data: data)
        }
    }

    sfCell.label?.text = usFlags.fullName
   
    return sfCell
    
}
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //send to park api contoller
        
        
          let parkDetailViewController = self.storyboard!.instantiateViewController(withIdentifier: "ParkDetailsViewController") as! ParkDetailViewController
        
        let flags = self.flagModel[(indexPath as NSIndexPath).row]
        debugPrint("ParkViewController: Selected Item \(flags.fullName)")

        self.abbrName = flags.abbrName
        
        
        //MARK CHECK TO SEE IF STATE EXISTS
        self.checkForExistingState(abbrName: flags.abbrName)
        
        
        parkDetailViewController.parkDoesNotExist = self.existingState
        
        parkDetailViewController.abbrName = self.abbrName
        self.navigationController!.pushViewController(parkDetailViewController, animated: true)
        
    }

}


extension ParkViewController {
    
 

//    fileprivate func configureDatabase() {
//        //MARK CALL FLAG API
//        // Do any additional setup after loading the view.
//        dbRef = Database.database().reference(withPath: "data")
//
//    }
//
//    fileprivate func configureStorage() {
//        storageRef = Storage.storage().reference()
//
//    }
//
    
    //Mark From Firebase
    fileprivate func loadFromDatabase(){
        LoadingViewActivity.show(self.collectionView, loadingText: "Loading")
        dbRef.observe(.value, with: {snapshot in

            //MARK Iterate over items FROM DATABASE
            var dataModel:[FlagsModel] = []
            for item in snapshot.children {

                if let snapshot = item as? DataSnapshot,
                    let flgItem =  FlagsModel(snapshot: snapshot){
                    dataModel.append(flgItem)
                }
                debugPrint("LOADFROM DATABASE: datamodel count.. \(dataModel.count)")

            }

            //MARK LOAD DATA INTO ARRAY AND RELOAD TABLE
            self.flagModel = dataModel
            self.collectionView.reloadData()

        })

        LoadingViewActivity.hide()
    }
    
   
}


//MARK CHECK FOR EXISTING STATE
extension ParkViewController {
    
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
