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
    
var stateUS: State!
    
var abbreviatedName: String!
    

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
        
        //MARK PRIOR TO CALLING DETAIL VIEW POPULATE CORE DATA
        self.abbreviatedName = flags.abbrName
        
        reloadMapView(abbrName: flags.abbrName)
        
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
                debugPrint("datamodel count.. \(dataModel.count)")
                
            }
            
            //MARK LOAD DATA INTO ARRAY AND RELOAD TABLE
            self.flagModel = dataModel
            self.collectionView.reloadData()
            
        })
        
        LoadingViewActivity.hide()
    }
    
    //MARK GET PARK DATA AND SAVE TO CORE DATA
    
    @objc func reloadMapView(abbrName: String){
        
        ParkApi.getNationalParks(url: EndPoints.getParks(abbrName).url, completionHandler: handleGetParkInfo(parkInfo:error:))
    }
    
    
    func handleGetParkInfo(parkInfo:[Parks]?, error:Error?){
        
        var existingState: Bool = false
        
        guard let parkInfo = parkInfo, !parkInfo.isEmpty else { return }
        
        
        //MARK CHECK TO SEE IF IT EXIST IN CORE DATA
        //MARK SAVE TO CORE DATA
        let fetchRequest:NSFetchRequest<State> = State.fetchRequest()
        
        let predicate = NSPredicate(format: "abbrName = %@", self.abbreviatedName)
        
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "abbrName", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if (try? dataController.viewContext.fetch(fetchRequest)) != nil{
            
            existingState = true
            
        }
        
        
        if(existingState) {
            
            //MARK SAVE STATE TO CORE DATA
            self.stateUS = State(context: dataController.persistentContainer.viewContext)
            stateUS.abbrName = self.abbreviatedName
            
            do {
                 try dataController.persistentContainer.viewContext.save()
            } catch let error {
                
                debugPrint(error.localizedDescription)
            }
        
        for info in parkInfo {
            
            let coordinates = info.coordinates
       
            
            if (!info.coordinates.isEmpty){
                
                
                let separators = CharacterSet(charactersIn: ":,")
                let coordinateParts = info.coordinates.components(separatedBy: separators)
                
                let latitude = (coordinateParts[1] as NSString).doubleValue
                let longitude  = (coordinateParts[3] as NSString).doubleValue
                
                let npCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                saveToCoreData(parkName: info.fullName, mediaUrl: info.parkUrl, title: info.designation, npCoordinates: npCoordinates)
                
                parkFilterByCoordinates.append(info)
                
                debugPrint("No Coordinates \(info.name), .... \(coordinates)")
                
            }
            
           }
            
        }
        
    }
    
    
    func saveToCoreData(parkName: String, mediaUrl: String, title: String, npCoordinates:CLLocationCoordinate2D){
        
        do{
           self.nationalPark = NationalPark(context: dataController.persistentContainer.viewContext)
                nationalPark.latitude  = npCoordinates.latitude
                nationalPark.longitude  = npCoordinates.longitude
                nationalPark.parks = parkName
                nationalPark.medialUrl = mediaUrl
                nationalPark.title = title
          
                debugPrint("ParkViewController \(String(describing: nationalPark.parks))")
            
            //MARK: When pins are dropped on the map, the pins are persisted as Pin instances in Core Data and the context is saved.
            try dataController.persistentContainer.viewContext.save()
            nationalParks.append(nationalPark)
            debugPrint("Saving NationalPark to Core data")
        }
        catch let error
        {
            debugPrint(error)
        }
        
    }
}
