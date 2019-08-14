//
//  ParkApi.swift
//  Parkacation
//
//  Created by Darin Williams on 8/4/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

// PARK  model
//"states": "TX",
//"latLong": "lat:29.29817767, long:-103.2297897",
//"description": "There is a place in Far West Texas where night skies are dark as coal and rivers carve temple-like canyons in ancient limestone. Here, at the end of the road, hundreds of bird species take refuge in a solitary mountain range surrounded by weather-beaten desert. Tenacious cactus bloom in sublime southwestern sun, and diversity of species is the best in the country. This magical place is Big Bend...",
//"designation": "National Park",
//"parkCode": "bibe",
//"id": "C9056F71-7162-4208-8AE9-2D0AEFA594FD",
//"directionsInfo": "Several highways lead to Big Bend National Park: TX 118 from Alpine to Study Butte or FM 170 from Presidio to Study Butte (then 26 miles east to park headquarters) or US 90 or US 385 to Marathon (then 70 miles south to park headquarters). \n\nDistances between towns and services are considerable. Be sure you have plenty of gas, oil, food, and water for your trip.",
//"directionsUrl": "http://www.nps.gov/bibe/planyourvisit/directions.htm",
//"fullName": "Big Bend National Park",
//"url": "https://www.nps.gov/bibe/index.htm",
//"weatherInfo": "Variable\n-- February through April the park abounds with pleasant and comfortable temperatures.\n-- May through August is hot and can also be stormy. Temperatures regularly reach well over 100 degrees in the lower elevations and along the Rio Grande.\n-- September through January temperatures are cooler; the weather can quickly turn cold at any time during these months.",
//"name": "Big Bend"


import Foundation

struct NationalParks: Codable {
    let data: [Parks]
}


struct Parks: Codable {
    let coordinates: String
    let designation: String
    let description: String
    let fullName: String
    let parkUrl: String
    let weatherInfo: String
    let name: String
    
    
    enum CodingKeys: String, CodingKey {
        case coordinates = "latLong"
        case designation = "designation"
        case description = "description"
        case fullName = "fullName"
        case parkUrl = "url"
        case weatherInfo = "weatherInfo"
        case name = "name"
        
    }
}


// MARK: - Bounds
struct Bounds: Codable {
    let northeast: [Geometry]
}

// MARK: - Geometry
struct Geometry: Codable {
    let lat, lng: Double
    
    enum CodingKeys: String, CodingKey {
        case lat = "lat"
        case lng = "lng"
    }
}

