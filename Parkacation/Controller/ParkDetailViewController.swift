//
//  ParkDetailViewController.swift
//  Parkacation
//
//  Created by Darin Williams on 8/4/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import Foundation

class ParkDetailViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource ,NSFetchedResultsControllerDelegate {

    
    var abbrName: String = ""
    
    var parkInformation: [Parks] = [Parks]()
    
    var parkFilterByCoordinates: [Parks] = [Parks]()
    
    var coordinates: [Geometry] = [Geometry]()
    
    //Create Array of Dicationaries
    var coorDictionary = [[Double:Double]]()
    
    //Hold Forward GEO Code
    var geoCoordinates = [Double : Double]()
    
    var parkLoctionCoord: CLLocationCoordinate2D?

    
    //lets set up dependencty injections
//    var dataController:DataController!
    
    var dataController: DataController! {
        var object = UIApplication.shared.delegate
        var appDelegate = object as! AppDelegate
        return appDelegate.dataController
    }
    
    
    //FETCH CONROLLER
    var genericfetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    var fetchedResultsController : NSFetchedResultsController<NationalPark>!
    
    
   var fetchResultsController : NSFetchedResultsController<State>!
    
    var nationalParks : [NationalPark] = []
    
    var nationalPark : NationalPark!
    
    var parks : [NationalPark] = []
    
    var stateUS: State!
    
    //MARK LETS GET PATH OR CORE DATA SQL LITE FILE TO VIEW
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    
    
    //Lets hold name of park
    var parkNames = [String]()
    
    
    var existingState: Bool = false
    

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tableView: UITableView!
    
     var mapAnnotations = [MKPointAnnotation]()
    


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        //MARK CORE DATA RELATIONSHIP
      self.stateUS = State(context: dataController.persistentContainer.viewContext)
        
        //MARK CORE DATA LOCATION
        debugPrint(self.paths[0])
        debugPrint("ParkDetailViewController: Here is the StateName \(String(describing: abbrName))")
        
        //Load coordinates data to Map of National Park
        LoadingViewActivity.show(mapView, loadingText: "Loading")

        
        checkForExistingState()
        
        if existingState {
            
            // CLEAR PINS FROM MAP
//            removeAllAnnotations()
            
            //MARK CALL COREDATA
            debugPrint("State exists so call Core Data")
            setUpFetchResultController()
            
            
            //RELOAD MAP ANNOTATIONS
            reloadMapAnnotations()
            
        } else {
            
            // CLEAR PINS FROM MAP
//            removeAllAnnotations()
            
            //CALL API
              debugPrint("State dones not exists so call API")
            reloadMapView(abbrName: self.abbrName)
            
            setUpFetchResultController()
            
            
            //RELOAD TABLE
            reloadMapAnnotations()
            
        }
        
        
        
        LoadingViewActivity.hide()

        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
    }
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        

          return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //MARK LOAD FROM CORE DATA
        let coreDataInformation = fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkCell")
     

        // ASSIGN NAME RETURN FROM PARK API TO TITLE
        cell?.textLabel?.text = coreDataInformation.parks
        

        cell?.detailTextLabel?.text = coreDataInformation.parks
        
        
        //ASSIGN DESCRIPTION FROM PARK API TO DETAIL
        
        return cell!
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let parkDirectionsController = self.storyboard!.instantiateViewController(withIdentifier: "ParkDirectionsViewController") as! ParkDirectionsViewController
        
        let parkLocation = fetchedResultsController.object(at: indexPath)
        
        //send coordinates from map
        debugPrint("here are the coordinates .. \(String(describing: parkLocation.parks))")
        
   

        let npCoordinates = CLLocationCoordinate2D(latitude: parkLocation.latitude, longitude: parkLocation.longitude)
        
        //Send Coordinates
        parkDirectionsController.parkLocation = npCoordinates
        
        
        //Send Park Name
        parkDirectionsController.parkName = parkLocation.parks
        
        self.navigationController?.pushViewController(parkDirectionsController, animated: true)
        
    }
    

}

extension ParkDetailViewController {
    
 
    //MARK SETUP FetchResult Contoller
    @discardableResult func setUpFetchResultController() -> [NationalPark]? {
        
        let fetchRequest : NSFetchRequest<NationalPark> = NationalPark.fetchRequest()
        
        let predicate = NSPredicate(format: "stateAbbrName == %@", self.abbrName)

        fetchRequest.predicate = predicate

        let sortDescriptor = NSSortDescriptor(key: "parks", ascending: false)
        //Use predicate to search
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //Instaniate fetch results controller
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil) as! NSFetchedResultsController<NationalPark>
        
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
            return parks
        } catch {
            return nil
        }
        
    }
    
 
    fileprivate func reloadMapAnnotations() {
        if !self.parks.isEmpty{
            for park in parks {
                
                //MARK ADD COORDINATES TO CORE DATA
                debugPrint("ParksDetailView: ViewDidLoad: Parks are not empty")
                addParkPin(coordinates: CLLocationCoordinate2D(latitude: park.latitude, longitude: park.longitude), title: park.title!, subtitle: park.medialUrl! )
                
                tableView.reloadData()
                
                
            }
            
        } else {
            
            debugPrint("Parks are empty")
            
        }
    }
    
    

    
    func handleParkCoordinates(parkCoord:[Geometry]?, error:Error?){


        guard let parkCoord = parkCoord else {
            showInfo(withMessage: "Unable to Download Park Coordinates")
            print(error!)
            return
        }

        for pk in parkCoord {
            debugPrint("Lat..\(pk.lat)....\(pk.lng)")
            self.geoCoordinates[pk.lat] = pk.lng
            self.coorDictionary.append(geoCoordinates)
            debugPrint("Size of dictionary \(self.coorDictionary.count)")
        }

        
        
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
    
    func createMapAnnotation(parkInfo:[Parks]) {
        
        debugPrint("createMapAnnotation: \(parkInfo.count)")
        for info in parkInfo {
            //Name of National Park
            let title = info.fullName
          
            
            //Parse Coordinates latLong": "lat:29.29817767, long:-103.2297897",
            let coordinates = info.coordinates
            
            guard case info.coordinates = info.coordinates, !info.coordinates.isEmpty else {
                
                  debugPrint("No Coordinates \(info.name)")
                  debugPrint("Count before finding missing latlong.. \(mapAnnotations.count)")
                return
            }
            
            
            let separators = CharacterSet(charactersIn: ":,")
            let coordinateParts = coordinates.components(separatedBy: separators)
            
            let latitude = (coordinateParts[1] as NSString).doubleValue
            let longitude  = (coordinateParts[3] as NSString).doubleValue
            
            let lat = CLLocationDegrees(latitude)
            let long = CLLocationDegrees(longitude)
          
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
             debugPrint("Here is the coordinate...\(coordinate)")
            //Park URL
            let mediaURL = info.parkUrl
            
            let annotation = MKPointAnnotation()
            annotation.title = title
            annotation.coordinate = coordinate
            annotation.subtitle = mediaURL
             debugPrint("Current Count \(mapAnnotations.count)")
            mapAnnotations.append(annotation)
        }
        
        self.mapView.addAnnotations(mapAnnotations)
        LoadingViewActivity.hide()
    }
    
    // each pin's rendering
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
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
    

    //MARK REMOVE ALL ANNOTATIONS
    func removeAllAnnotations() {
        for annotation in self.mapView.annotations {
            self.mapView.removeAnnotation(annotation)
        }
    }
}

extension ParkDetailViewController {
    
    func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View
        
        if let error = error {
            debugPrint("Unable to Forward Geocode Address (\(error))")
            
        } else {
            var location: CLLocation?

            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
                debugPrint("first location")
            }
            
            if let location = location {
                let coordinate = location.coordinate
                
                var dictionaryOrCoord: [Double : Double] = [coordinate.latitude : coordinate.longitude]
                
                //appenad to dictionary
                coorDictionary.append(dictionaryOrCoord)
                 debugPrint("\(coordinate.latitude), \(coordinate.longitude)")
            } else {
                 debugPrint("No Matching Location Found")
            }
        }
    }

    
    
}

extension ParkDetailViewController {
    
    //MARK GET PARK DATA AND SAVE TO CORE DATA
    
    @objc func reloadMapView(abbrName: String){
        
        ParkApi.getNationalParks(url: EndPoints.getParks(abbrName).url, completionHandler: handleGetParkInfo(parkInfo:error:))
    }
    
    
    fileprivate func checkForExistingState() {
        //MARK CHECK TO SEE IF IT EXIST IN CORE DATA
        //MARK SAVE TO CORE DATA
        let fetchRequest:NSFetchRequest<State> = State.fetchRequest()
        
        let predicate = NSPredicate(format: "abbrName == %@", self.abbrName)
        
        fetchRequest.predicate = predicate
        
        fetchRequest.fetchLimit = 1
        
        
        let sortDescriptor = NSSortDescriptor(key: "abbrName", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
      
        genericfetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil) as? NSFetchedResultsController<State> as! NSFetchedResultsController<NSFetchRequestResult>
        
//        fetchedResultsController.delegate = self
        
        do {
            try genericfetchedResultsController.performFetch()
        } catch  let error {
            debugPrint("DetatilViewController: catchStatement \(error.localizedDescription)")
            fatalError(error.localizedDescription)
        }
        
        
        do {
            
            let totalCount = try genericfetchedResultsController.managedObjectContext.count(for: fetchRequest)
            
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
    
    
    func handleGetParkInfo(parkInfo:[Parks]?, error:Error?){
        

        guard let parkInfo = parkInfo, !parkInfo.isEmpty else { return }
        
    
            //MARK SAVE STATE TO CORE DATA
           stateUS.abbrName = self.abbrName

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
                    
                    saveToCoreData(parkName: info.fullName, mediaUrl: info.parkUrl, title: info.name, npCoordinates: npCoordinates)
                    
                    parkFilterByCoordinates.append(info)
                    
                    debugPrint("No Coordinates \(info.name), .... \(coordinates)")
                    
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
            nationalPark.stateAbbrName = self.abbrName
            
            debugPrint("ParkViewController \(String(describing: nationalPark.parks))")
            
            //MARK: When pins are dropped on the map, the pins are persisted as Pin instances in Core Data and the context is saved.
            try dataController.persistentContainer.viewContext.save()
            parks.append(nationalPark)
            debugPrint("Saving NationalPark to Core data")
        }
        catch let error
        {
            debugPrint(error)
        }
        
    }
    
    
    
}
