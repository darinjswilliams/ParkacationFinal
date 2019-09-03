//
//  FavoriteParksViewController.swift
//  Parkacation
//
//  Created by Darin Williams on 8/25/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Foundation

class FavoriteParksViewController: UIViewController, MKMapViewDelegate,UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    

    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var noParkLabel: UILabel!
    
    var mapAnnotations = [MKPointAnnotation]()
    
    
    @IBOutlet weak var tableView: UITableView!
    var favoritePark: String?
    
    private var blockOperation = BlockOperation()
    
    
    var parkCoordinates : CLLocationCoordinate2D?
    
   
    //lets set up dependencty injections
    //var dataController:DataController!
    
    var dataController: DataController! {
        var object = UIApplication.shared.delegate
        var appDelegate = object as! AppDelegate
        return appDelegate.dataController
    }
    
    var nationalParks : [NationalPark] = []
    
    var nationalPark : NationalPark!
    
    var parks : [NationalPark] = []
    
    var favoriteParksFound: Bool!
    
  
    
    var fetchedResultsController : NSFetchedResultsController<NationalPark>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handleSignOut))
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
        LoadingViewActivity.show(self.tableView, loadingText: "Loading Favorite Parks")
            
        // Do any additional setup after loading the view.
        self.favoritePark = "Favorite"
        
        checkForFavoriteParks()
        
        if !favoriteParksFound! {
            
            // Mark no favorie park
            debugPrint("No Favoite Parks")
            self.noParkLabel?.text = "No Favorite Park Marked"
            
       
            showInfo(withMessage: "No Favorite Park Marked")
              
          
            
        } else {
            debugPrint("Favoite Parks Found")
         
            if !parks.isEmpty {
                for park in parks {
                    let coordinates = CLLocationCoordinate2D(latitude: park.latitude, longitude: park.longitude)
                    addParkPin(coordinates: coordinates, title: park.title!, subtitle: park.medialUrl!)
                }
            }
            
            self.tableView.reloadData()
//
//            self.mapView.reloadInputViews()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        LoadingViewActivity.hide()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //MARK LOAD FROM CORE DATA
        let coreDataInformation = fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteParks")
        
        
        // ASSIGN NAME RETURN FROM PARK API TO TITLE
        cell?.textLabel?.text = coreDataInformation.stateAbbrName
        
        
        cell?.detailTextLabel?.text = coreDataInformation.parks
        
        
        //ASSIGN DESCRIPTION FROM PARK API TO DETAIL
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        do {
    
            
            let parkLocation = fetchedResultsController.object(at: indexPath)
            
            debugPrint("Update Core DAta Visit for \(String(describing: parkLocation.parks))")
           
            
            //MARK Remove Favorite Name assigin to park in CoreData
            parkLocation.setValue(nil, forKey: "visit")
            
            try dataController.persistentContainer.viewContext.save()
            
            
            let lat = CLLocationDegrees(parkLocation.latitude)
            let long = CLLocationDegrees(parkLocation.longitude)
            
            debugPrint("\(lat) and \(long)")
            
            
            let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
    
            
            
            let alert = UIAlertController(title: "Remove Park from Favorites", message: "You can add the park again!", preferredStyle: .alert)
            
            

            self.parks.removeAll()
            
            checkForFavoriteParks()
            
            
           updateUIMapAnnotation()
     
            self.tableView.reloadData()
            
        } catch let error {
            debugPrint("FavoriteParkController: \(error.localizedDescription)")
        }
        
    }
    
    
    
    @IBAction func pinPressed(_ sender: UILongPressGestureRecognizer) {
        
        //MARK CHECK PIN FOR STATE
        print("here is the value \(sender.state.rawValue)")
        
        let location = sender.location(in: mapView)
        
        let coordinates = mapView.convert(location, toCoordinateFrom: self.mapView)
        
        // Save pin to CoreData
        // COMMENTED OUT FOR 2ND REVIEW
        //pin = Pin(context: dataController.persistentContainer.viewContext)
        
        if sender.state != .began {
            return
        }
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        
        //        pin.latitude = travelCoordinates!.latitude
        //        pin.longitude = travelCoordinates!.longitude
        //        pin.coordinates = String(pin.latitude)+String(pin.longitude)
        
        let long = coordinates.longitude
        let lat = coordinates.latitude
        //        let pin = Pin(context: dataController.persistentContainer.viewContext)
        
        annotation.title = String(lat)+String(long)
        
        // Update Pins
        updateUIMapAnnotation()

        
        
//        let region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//        
//        mapView.setRegion(region, animated: true)
//        
//        mapView.addAnnotation(annotation)
//        
//        
//        savePinLocationToCoreData(longitude: long, latitude: lat)
        
        
    }
    
      private func updateUIMapAnnotation() {
        
        // clean up annotations first
       DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        for dictionary in self.parks {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            
            
            let lat = CLLocationDegrees(dictionary.latitude as Double)
            let long = CLLocationDegrees(dictionary.longitude as Double)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            

            let mediaURL = dictionary.medialUrl
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            
    
            annotations.append(annotation)
        
        }
        
       DispatchQueue.main.async {
            // When the array is complete, we add the annotations to the map.
//            self.mapView.addAnnotations(annotations)
        
        
        if !self.parks.isEmpty {
            for park in self.parks {
                let coordinates = CLLocationCoordinate2D(latitude: park.latitude, longitude: park.longitude)
                self.addParkPin(coordinates: coordinates, title: park.title!, subtitle: park.medialUrl!)
            }
        }
        
        
        
        }
        
        
        
    }


}

extension FavoriteParksViewController: NSFetchedResultsControllerDelegate {
    
    
    //MARK SETUP FetchResult Contoller
    @discardableResult func checkForFavoriteParks() -> [NationalPark]? {
        
        
        let fetchRequest : NSFetchRequest<NationalPark> = NationalPark.fetchRequest()
        
        let predicate = NSPredicate(format: "visit == %@", self.favoritePark!)
        
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "parks", ascending: false)
        //Use predicate to search
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //Instaniate fetch results controller
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        //MARK set fetch result controller delegate
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch  {
            fatalError("Fetching the Parks could not be performed \(error.localizedDescription)")
        }
        
        
        //MARK GET National Parks
        do {
            let totalParks = try fetchedResultsController.managedObjectContext.count(for: fetchRequest)
            for i in 0..<totalParks {
                self.parks.append(fetchedResultsController.object(at: IndexPath(row: i, section: 0)))
            }
            favoriteParksFound = true
            return parks
        } catch {
           favoriteParksFound = false
            return nil
        }
        
    }
    
    
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { break }
            
            blockOperation.addExecutionBlock {
                self.tableView?.insertRows(at: [newIndexPath], with: UITableView.RowAnimation.none)
            }
        case .delete:
            guard let indexPath = indexPath else { break }
            
            blockOperation.addExecutionBlock {
                self.tableView?.deleteRows(at: [indexPath], with: UITableView.RowAnimation.none)
            }
        case .update:
            guard let indexPath = indexPath else { break }
            
            blockOperation.addExecutionBlock {
                self.tableView?.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            }
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            
            blockOperation.addExecutionBlock {
                self.tableView?.moveRow(at: indexPath, to: newIndexPath)
            }
        }
    }
    
    
    fileprivate func reloadMapAnnotations() {
//        if !self.parks.isEmpty{
            for park in parks {
                
                //MARK ADD COORDINATES TO CORE DATA
               
                guard let title = park.title else {
                    debugPrint("ParksDetailView: Title Parks are empty \(String(describing: park.title))")
                    return
                }
                
                
                guard let media = park.medialUrl else {
                    debugPrint("ParksDetailView: Medial Parks are empty \(String(describing: park.medialUrl))")
                    return
                }
                
                DispatchQueue.main.async {
              
                    self.addParkPin(coordinates: CLLocationCoordinate2D(latitude: park.latitude, longitude: park.longitude), title: title, subtitle: media )
            
                }
            }
            
//        } else {
//
//            debugPrint("Parks are empty")
//
//        }
    }
    
    
    func addParkPin(coordinates: CLLocationCoordinate2D, title: String, subtitle: String) {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = coordinates
       
        mapView.addAnnotation(annotation)
        mapAnnotations.append(annotation)
        mapView.showAnnotations(mapAnnotations, animated: true)
         
    }
    
    
//    // each pin's rendering
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
     
        let annotationId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId) as? MKPinAnnotationView

//            pinView?.addGestureRecognizer(doubleTabRecognizer)

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .blue
            pinView?.rightCalloutAccessoryView = UIButton(type:.detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control == view.rightCalloutAccessoryView) {
            let app = UIApplication.shared
            if let url = view.annotation?.subtitle! {
                guard !url.isEmpty else {
                    showInfo(withMessage: "No Valid URl")
                    return
                }
                app.open(URL(string: url)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if (fullyRendered) {
            performUIUpdatesOnMain {
                 LoadingViewActivity.hide()
            }
        }
    }
    
}

extension FavoriteParksViewController {
    
    
    @IBAction func removeFavoritePark(_ sender: UILongPressGestureRecognizer) {
        
        debugPrint("Remove favorite park")
        
        let location = sender.location(in: mapView)
        
        parkCoordinates = mapView.convert(location, toCoordinateFrom: self.mapView)
        
        
        if sender.state != .began {
            return
        }
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        
        
        annotation.coordinate = parkCoordinates!
        
        
        let long = parkCoordinates!.longitude
        let lat = parkCoordinates!.latitude
        //        let pin = Pin(context: dataController.persistentContainer.viewContext)
        for park in parks {
            
            debugPrint("here is park \(park.latitude).. longitude ..\(park.longitude)")
            
            debugPrint("latitude to match \(lat)..long..\(long)")
            
            if park.latitude == lat && park.longitude == long {
                
                debugPrint("State \(String(describing: park.stateAbbrName))")
                debugPrint(park.parks)
                debugPrint(park.state)
                debugPrint(park.title)
                debugPrint(park.medialUrl)
                debugPrint(park.latitude)
                debugPrint(park.longitude)
                debugPrint(park.visit)
            }
            
            
        }
        
        annotation.title = String(lat)+String(long)
        
        
    }
    
}
