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
    
    var coordinates2D:CLLocationCoordinate2D?
    
    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    var mapAnnotations = [MKPointAnnotation]()
    
    var totalDistance: Double!
    
    var etaTotalTime: Double!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view.
        debugPrint("Here are the park coordination \(String(describing: parkLocation?.latitude)) and \(String(describing: parkLocation?.longitude))")
      
        
        //Ask User for Permission to get current location
        self.locationManager.requestWhenInUseAuthorization()
        
        //Generate Popup for user
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
    
    
    
    // MARK DISPLAY USERS CURRENT LOCATION ON MAP
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
  
       
        // GET USER CURRENT LOCATION
        let locVal:CLLocationCoordinate2D = manager.location!.coordinate
        
        debugPrint(("location latitude = \(locVal.latitude) and Longitude = \(locVal.longitude)"))
        
        let userName = "current position"
        
        self.coordinates2D = locVal
        
        self.createRouteOnMap(sourceInfo: self.parkLocation!, destinationInfo: locVal)
        self.createMapAnnotation(directionsInfo: self.parkLocation!, directionsName: self.parkName!)
        self.createMapAnnotation(directionsInfo: locVal, directionsName: userName)
        
        //Stop fetching users location
        locationManager.stopUpdatingHeading()
        
        LoadingViewActivity.hide()
        
    }

}

extension ParkDirectionsViewController {
    
    func createMapAnnotation(directionsInfo:CLLocationCoordinate2D, directionsName: String) {
        
        debugPrint("createMapAnnotation: \(directionsInfo.latitude) & \(directionsInfo.longitude)")

            let annotation = MKPointAnnotation()
            annotation.title = directionsName
            annotation.coordinate = directionsInfo
        
        if (directionsName.contains("current position")){
          
            annotation.subtitle = "Travel Time \(self.etaTotalTime)..Total Distance \(self.totalDistance)"
        }
            debugPrint("Current Count \(mapAnnotations.count)")
            mapAnnotations.append(annotation)
        
           self.mapView.addAnnotations(mapAnnotations)
        
    }
    
    
    func createRouteOnMap(sourceInfo:CLLocationCoordinate2D, destinationInfo: CLLocationCoordinate2D){
        
    LoadingViewActivity.show(mapView, loadingText: "Calculating Fastest Route")
        
        let  sourcePlaceMark  = MKPlacemark(coordinate: sourceInfo)
        let destinationPlaceMark  = MKPlacemark(coordinate: destinationInfo)
        let directionRequest = MKDirections.Request()
        
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        
        
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
            
            // GET Distanceo on Route and convert to meters to miles  dividing by 1609.44
            let distance = route.distance
            debugPrint(("here is the distance \(distance/AuthenticationUtils.convertMetersToMiles)"))
            
            //MARK ROUND Distance
            self.totalDistance = round(distance/AuthenticationUtils.convertMetersToMiles)
            debugPrint("Round total distance .. \(String(describing: self.totalDistance))")
            
            
            //GET ETA and convert seconds to Hours
            let eta = route.expectedTravelTime
               debugPrint(("here is the ETA \(eta/AuthenticationUtils.convertSecondsToHours)"))
            
            self.etaTotalTime = (eta/AuthenticationUtils.convertSecondsToHours)
            debugPrint("Round total time .. \(String(describing: self.etaTotalTime))")
            
            
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            
            //Set Bounding on Map
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
        
        
        self.mapView.delegate = self
        
    }
    
    //MARK mapview overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        
        render.strokeColor = UIColor.blue
        render.lineWidth = 4.0
        
        return render
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
