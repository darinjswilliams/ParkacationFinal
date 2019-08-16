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
    var dataController:DataController!
    
    
    //FETCH CONROLLER
    var fetchedResultsController : NSFetchedResultsController<NationalPark>!
    
    var parks : [NationalPark] = []
    
    //MARK LETS GET PATH OR CORE DATA SQL LITE FILE TO VIEW
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
 
    
    
    //Lets hold name of park
    var parkNames = [String]()
    

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tableView: UITableView!
    
     var mapAnnotations = [MKPointAnnotation]()
    
    
    //Get instance of CLGeocoder
    lazy var geoParkCoder = CLGeocoder()
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        debugPrint("ParkDetailViewController: Here is the StateName \(String(describing: abbrName))")
        
        //Load coordinates data to Map of National Park
        LoadingViewActivity.show(mapView, loadingText: "Loading")
//        reloadMapView()
        reloadMapView()
      
//        mapView.delegate = self
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    
    @IBAction func pinPressed(_ sender: UILongPressGestureRecognizer) {
        
        debugPrint("here is the value \(sender.state.rawValue)")
        
        let location = sender.location(in: mapView)
        
        parkLoctionCoord = mapView.convert(location, toCoordinateFrom: self.mapView)
        
        debugPrint("Park Coordinates = \(String(describing: parkLoctionCoord?.latitude)) and \(String(describing: parkLoctionCoord?.longitude))")
        
        if sender.state != .began {
            return
        }
        
        
        
        
    }
    
    
    func geoCodeParkName(){
        
        for fndPark in parkNames {
            debugPrint("\(fndPark)")
            
            ParkApi.getParkCoordinates(url: EndPoints.getCoordinates(fndPark).url, completionHandler: handleParkCoordinates(parkCoord:error:))
            
        }
        
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.parkInformation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkCell")
     
        //TODO
        // ASSIGN NAME RETURN FROM PARK API TO TITLE
        cell?.textLabel?.text = self.parkInformation[indexPath.row].fullName
        cell?.detailTextLabel?.text = self.parkInformation[indexPath.row].designation
        
        
        //ASSIGN DESCRIPTION FROM PARK API TO DETAIL
        
        return cell!
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let parkDirectionsController = self.storyboard!.instantiateViewController(withIdentifier: "ParkDirectionsViewController") as! ParkDirectionsViewController
        
        let parkLocation =  self.parkInformation[(indexPath as NSIndexPath).row]
        
        //send coordinates from map
        debugPrint("here are the coordinates .. \(parkLocation.coordinates)")
        
   
        let separators = CharacterSet(charactersIn: ":,")
        let coordinateParts = parkLocation.coordinates.components(separatedBy: separators)
        
        let latitude = (coordinateParts[1] as NSString).doubleValue
        let longitude  = (coordinateParts[3] as NSString).doubleValue
        
        let npCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        //Send Coordinates
        parkDirectionsController.parkLocation = npCoordinates
        
        
        //Send Park Name
        parkDirectionsController.parkName = parkLocation.fullName
        
        self.navigationController?.pushViewController(parkDirectionsController, animated: true)
        
    }
    

}

extension ParkDetailViewController {
    
    
    @objc func reloadMapView(){
        
        ParkApi.getNationalParks(url: EndPoints.getParks(self.abbrName).url, completionHandler: handleGetParkInfo(parkInfo:error:))
    }
    
    //MARK SETUP FetchResult Contoller
    @discardableResult func setUpFetchResultController() -> [NationalPark]? {
        
        let fetchRequest : NSFetchRequest<NationalPark> = NationalPark.fetchRequest()
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
            fatalError("Fetching the Pins could not be performed \(error.localizedDescription)")
        }
        
        
        //MARK GET PINS
        do {
            let totalParks = try fetchedResultsController.managedObjectContext.count(for: fetchRequest)
            for i in 0..<totalParks {
                parks.append(fetchedResultsController.object(at: IndexPath(row: i, section: 0)))
            }
            return parks
        } catch {
            return nil
        }
        
    }
    
    
    func handleGetParkInfo(parkInfo:[Parks]?, error:Error?){
        
        guard let parkInfo = parkInfo, !parkInfo.isEmpty else { return }
        
        
         for info in parkInfo {
            
            let coordinates = info.coordinates
            
            
            if (!info.coordinates.isEmpty){
            
                parkFilterByCoordinates.append(info)
                
                debugPrint("No Coordinates \(info.name), .... \(coordinates)")
            
            }
            
        
        
        }
        
        
        debugPrint("Count of items in \(parkFilterByCoordinates.count)")
        parkInformation = parkFilterByCoordinates
        
        debugPrint("Count of items in \(parkInformation.count)")
        
        createMapAnnotation(parkInfo:parkInformation)
        
        DispatchQueue.main.async {
            // reload table
            self.tableView.reloadData()
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
    
    
    func addPin(coordinates: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
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