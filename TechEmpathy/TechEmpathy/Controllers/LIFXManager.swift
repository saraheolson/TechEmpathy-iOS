//
//  LIFXManager.swift
//  TechEmpathy
//
//  Created by Sarah Olson on 4/21/17.
//  Copyright © 2017 SarahEOlson. All rights reserved.
//

import Foundation

class LIFXManager {

    private let LIFX_Token = "c2dcb3c97dba437f9f1633b07d1216493a8f5cf6419547458cb8e70e99fa6a65"

    public func updateAllLights(color: String) {
        
        let loginString = String(format: "%@:%@", LIFX_Token, "")
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        // create the request
        let url = URL(string: "https://api.lifx.com/v1/lights/all/state")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
  
        let parameters = [
            "power": "on",
            "color": color,
            ]
        
        do {
        if let data = try JSONSerialization.data(withJSONObject: parameters, options:JSONSerialization.WritingOptions(rawValue: 0)) as NSData? {
            request.httpBody = data as Data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("\(data.length)", forHTTPHeaderField: "Content-Length")
        }
        } catch {
            print("Error creating parameters for LIFX API call.")
        }
        
        let config = URLSessionConfiguration.default
        let authString = "Basic \(base64LoginString)"
        config.httpAdditionalHeaders = ["Authorization" : authString]
        let session = URLSession(configuration: config)
        
        session.dataTask(with: request) { ( data, response, error) in
            if error != nil {
                print("Error occurred: \(String(describing: error))")
            }
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let results = json["results"] as? [[String: Any]],
                    let status = results[0]["status"] as? String {
                    
                    if status == "ok" {
                        print("Success!")
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
        }.resume()
    }
}
