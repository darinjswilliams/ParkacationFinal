//
//  ParkApi.swift
//  Parkacation
//
//  Created by Darin Williams on 8/4/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation

class ParkApi {
    
    class func getNationalParks(url: URL, completionHandler: @escaping ([Parks]?, Error?)-> Void){
        
        taskForGetParkRequest(url: url) { (response, error) in
            guard let response = response else {
                debugPrint("requestforParks: Failed")
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            debugPrint("request for Parks: good")
            DispatchQueue.main.async {
                completionHandler(response, error)
            }
        }
    }
    
    class func getParkCoordinates(url: URL, completionHandler: @escaping ([Geometry]?, Error?)-> Void){
        
        taskForGetCoordinates(url: url) { (response, error) in
            guard let response = response else {
                debugPrint("requestfor Park Coordinates: Failed")
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            debugPrint("request for Park Coordinates: good")
            DispatchQueue.main.async {
                completionHandler(response, error)
            }
        }
    }
    
    fileprivate static func getRequestHeaders(_ request: inout URLRequest) {
        request.httpMethod = AuthenticationUtils.headerGet
        request.addValue(AuthenticationUtils.contentTypeValue, forHTTPHeaderField: AuthenticationUtils.headerContentTypeKey)
        request.addValue(AuthenticationUtils.parkApiKey, forHTTPHeaderField: AuthenticationUtils.headerXapiKey)
    }
    
    class func taskForGetParkRequest(url: URL, completionHandler: @escaping ([Parks]?,Error?)->Void) {
        var request = URLRequest(url: url)
        
        getRequestHeaders(&request)
        
        let downloadTask = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            // guard there is data
            guard let data = data else {
                // TODO: CompleteHandler can return error
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            let jsonDecoder = JSONDecoder()
            do {
                let result = try jsonDecoder.decode(NationalParks.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(result.data, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
            }
        }
        
        downloadTask.resume()
    }
    
    
    
    
    class func taskForGetCoordinates(url: URL, completionHandler: @escaping ([Geometry]?,Error?)->Void) {
        var request = URLRequest(url: url)
        
        request.httpMethod = AuthenticationUtils.headerGet
        request.addValue(AuthenticationUtils.contentTypeValue, forHTTPHeaderField: AuthenticationUtils.headerContentTypeKey)
        
        
        
        let downloadTask = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            // guard there is data
            guard let data = data else {
                // TODO: CompleteHandler can return error
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            let jsonDecoder = JSONDecoder()
            do {
                let result = try jsonDecoder.decode(Bounds.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(result.northeast, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
            }
        }
        
        downloadTask.resume()
    }
    
    
}
