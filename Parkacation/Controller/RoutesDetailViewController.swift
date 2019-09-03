//
//  RoutesDetailViewController.swift
//  Parkacation
//
//  Created by Darin Williams on 9/2/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import UIKit
import MapKit

class RoutesDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var routeDirections = [String]()
    
    var routeETA: Double!
    
    var routeDistance: Double!

    @IBOutlet weak var etaLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        debugPrint("RouteDetailsViewController: \(String(describing: routeETA))")
        debugPrint("RouteDetailsViewController: \(String(describing: routeDistance))")
        debugPrint("RouteDetailsViewController: \(routeDirections.count)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
           navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handleSignOut))
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.routeDirections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteCell")
        
        self.etaLabel.text = NSString(format: "%.2f", self.routeETA) as String
        
        self.distanceLabel.text = NSString(format: "%.1f", self.routeDistance) as String
        
        
        let directions = self.routeDirections[(indexPath  as NSIndexPath).row]
        
        cell?.textLabel?.text = directions
        
        return cell!
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    

}
