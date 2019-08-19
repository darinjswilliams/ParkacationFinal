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

class ParkViewController: UIViewController,  UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate
{
    
    
var allStates = USFlags.allFlags
    
@IBOutlet weak var collectionView: UICollectionView!
    
var dbRef: DatabaseReference!
    
var storageRef: StorageReference!
    
var flagModel = [FlagsModel]()
    
var parkFilterByCoordinates: [Parks] = [Parks]()
    
var fetchedResultsController : NSFetchedResultsController<NationalPark>!

var nationalParks : [NationalPark] = []
    
var nationalPark : NationalPark!
    
  

//lets set up dependencty injections
    
    var dataController: DataController! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.dataController
    }
    

    
override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
}

    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        configureDatabase()
        configureStorage()
        loadFromDatabase()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
    }
    

func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
   return self.flagModel.count
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let sfCell = collectionView.dequeueReusableCell(withReuseIdentifier: "StateFlagCollectionViewCell", for: indexPath) as! StateFlagCollectionViewCell
    
    // Configure the cell
    let usFlags = self.flagModel[(indexPath as NSIndexPath).row]
    
//    sfCell.photoImage?.image = UIImage(named: flags.flagImage)
    if let imageURL = usFlags.flagImage as? String {
        if imageURL.hasPrefix("gs://") {
            Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX) {(data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
                DispatchQueue.main.async {
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

        
//        reloadMapView(abbrName: flags.abbrName)
        
        parkDetailViewController.abbrName = flags.abbrName
        self.navigationController!.pushViewController(parkDetailViewController, animated: true)
        
    }
  


}


extension ParkViewController {
    
 

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
