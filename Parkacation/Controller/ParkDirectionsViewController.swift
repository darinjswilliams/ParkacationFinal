//
//  ParkDirectionsViewController.swift
//  Parkacation
//
//  Created by Darin Williams on 8/9/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import UIKit
import MapKit

class customPin {
    
    
}

//MARK CLASS MUST CONFROM TO CLLOcationManagerDelegate

class ParkDirectionsViewController: UIViewController, MKMapViewDelegate {

    //Park Coordinates
    var sourceLocation:CLLocationCoordinate2D?
    
    var parkLocation: CLLocationCoordinate2D?
    
    var parkName: String?
    
    var stateFlag: String?
    
    var coordinates2D:CLLocationCoordinate2D?
    
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var mapAnnotations = [MKPointAnnotation]()
    
    var totalDistance: Double!
    
    var etaTotalTime: Double!
    
    var routeInstruction = [String]()
    var routeETA: String!
    var routeDistance: String!
    
    @IBOutlet weak var parksLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         LoadingViewActivity.show(mapView, loadingText: "Calculating Fastest Route")
        
        
        // Do any additional setup after loading the view.
        debugPrint("Here are the park coordination \(String(describing: parkLocation?.latitude)) and \(String(describing: parkLocation?.longitude))")
      
        
        //Ask User for Permission to get current location
        self.locationManager = CLLocationManager()
        self.locationManager.requestWhenInUseAuthorization()
        
        
        //Generate Popup for user
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handleSignOut))
        
        LoadingViewActivity.hide()
        self.mapView.showsUserLocation = true
        self.mapView.userTrackingMode = .follow
    }
    
    
    // MARK DISPLAY USERS CURRENT LOCATION ON MAP
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
  
    
        // GET USER CURRENT LOCATION
        let locVal:CLLocationCoordinate2D = manager.location!.coordinate
        
        debugPrint(("location latitude = \(locVal.latitude) and Longitude = \(locVal.longitude)"))
        
        
        self.coordinates2D = locVal
        
        //MARK CHECK TO SEE IF STATE IS HAWAII
        if((self.stateFlag?.lowercased().contains("hi"))!){
            self.parksLabel.text = "No Driving Route Available, Call Travel Agent"
            } else {
        self.createRouteOnMap(sourceInfo: self.parkLocation!, destinationInfo: locVal)
            }

        locationManager.stopUpdatingHeading()

    }

}

extension ParkDirectionsViewController {
    
    func createMapAnnotation(directionsInfo:CLLocationCoordinate2D, directionsName: String) {
        
        debugPrint("createMapAnnotation: \(directionsInfo.latitude) & \(directionsInfo.longitude)")

            let annotation = MKPointAnnotation()
            annotation.title = directionsName
            annotation.coordinate = directionsInfo
        
        if (directionsName.contains("current position")){
          
            annotation.subtitle = "Travel Time \(String(describing: self.etaTotalTime))..Total Distance \(String(describing: self.totalDistance))"
        }
            debugPrint("Current Count \(mapAnnotations.count)")
            mapAnnotations.append(annotation)
        
           self.mapView.addAnnotations(mapAnnotations)
        
    }
    
    
    func createRouteOnMap(sourceInfo:CLLocationCoordinate2D, destinationInfo: CLLocationCoordinate2D){
 
        let  sourcePlaceMark  = MKPlacemark(coordinate: sourceInfo)
        let destinationPlaceMark  = MKPlacemark(coordinate: destinationInfo)
        let directionRequest = MKDirections.Request()
        
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
      
        let parkPoint = ParkAnnotation(coordinate: sourceInfo)
        
            parkPoint.title = self.parkName!
        
        //MARK type of transportation
        directionRequest.transportType = .automobile
        
        //MARK specified directions
        let directions = MKDirections(request: directionRequest)
        
        //Calculate Diredtions
        directions.calculate { (response, error) in
            guard let directionResposne = response else {
                if let error = error {
                    debugPrint("No route available \(error.localizedDescription)")
                }
                
                return
            }
            
            //MARK define  fastest route, marking with zero indicates fastest
            let route = directionResposne.routes[0]

            for step in route.steps {
                
                debugPrint(step.instructions)
                
                //Populate instructions
                self.routeInstruction.append(step.instructions)
                
            }
            
            // GET Distanceo on Route and convert to meters to miles  dividing by 1609.44
            let distance = route.distance
            debugPrint(("here is the distance \(distance/AuthenticationUtils.convertMetersToMiles)"))
            
            //MARK ROUND Distance
            self.totalDistance = round(distance/AuthenticationUtils.convertMetersToMiles)
            debugPrint("Round total distance .. \(String(describing: self.totalDistance))")
            parkPoint.mile = "\(String(describing: self.totalDistance)).. miles"
            
            
            //GET ETA and convert seconds to Hours
            let eta = route.expectedTravelTime
               debugPrint(("here is the ETA \(eta/AuthenticationUtils.convertSecondsToHours)"))
            
            self.etaTotalTime = (eta/AuthenticationUtils.convertSecondsToHours)
            debugPrint("Round total time .. \(String(describing: self.etaTotalTime))")
            parkPoint.eta = "\(String(describing: self.etaTotalTime)) .. min"
            
            
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            
            //Set Bounding on Map
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
        
   
        
        self.mapView.addAnnotation(parkPoint)
        self.mapView.delegate = self
        
    }
    
    //MARK mapview overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        
        render.strokeColor = UIColor.blue
        render.lineWidth = 4.0
        
        return render
    }
    
    
    // When button is tap perform a seque and to look at map directions and eta
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
        
        performSegue(withIdentifier: "routeDetails", sender: self)
    }
    

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // If annotation is not of type RestaurantAnnotation (MKUserLocation types for instance), return nil
            if !(annotation is ParkAnnotation){
                return nil
            }
            
            var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
            
            if annotationView == nil{
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
                annotationView?.canShowCallout = true
            }else{
                annotationView?.annotation = annotation
            }
            
            let parkAnnotation = annotation as! ParkAnnotation
            annotationView?.detailCalloutAccessoryView = UIImageView(image: parkAnnotation.image)
        
             //MARK Display extra information in callout bubble
             annotationView!.canShowCallout = true

        
           //Mark Add a Button
        let infoButton = UIButton(type: .infoDark) as UIButton
        
        
        annotationView?.rightCalloutAccessoryView = infoButton
        
            
            // Right accessory view
           let image = UIImage(named:  (self.stateFlag?.lowercased())!)
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            button.setImage(image, for: UIControl.State())
            annotationView?.leftCalloutAccessoryView = button
        
  
            return annotationView
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "routeDetails" {
            let dest = segue.destination as! RoutesDetailViewController
            
            dest.routeDirections = self.routeInstruction.reversed()
            dest.routeETA = self.etaTotalTime
            dest.routeDistance = self.totalDistance
            
        }
    }
    
}

extension ParkDirectionsViewController: CLLocationManagerDelegate {
    
    //Mark handle user permission
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied: debugPrint("Request Denied")
              return
        
        case .authorizedAlways: debugPrint("Authorized Always")
              break
        
        case .authorizedWhenInUse: debugPrint("Authorized when in use")
              break
            
        default: debugPrint("Location Permission is not set")
            return
        }
    }
    
}
