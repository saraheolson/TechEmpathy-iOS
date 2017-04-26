//
//  LIFXManager.swift
//  TechEmpathy
//
//  Created by Sarah Olson on 4/21/17.
//  Copyright © 2017 SarahEOlson. All rights reserved.
//

import Foundation

class LIFXManager {

    static let sharedInstance: LIFXManager = LIFXManager()
    
    private init() {
        if let lifxPrompted = UserDefaults.standard.value(forKey: self.LIFX_PromptedKey) as? String {
            if lifxPrompted == LIFX_PromptedValue {
                self.hasBeenPromptedForLifx = true
            }
        }
    }
    
    private let LIFX_APIKey = "com.saraheolson.techempathy.LIFXToken"
    private let LIFX_PromptedKey = "com.saraheolson.techempathy.LIFXPrompted"
    private let LIFX_PromptedValue = "prompted"

    public private(set) var hasLamp = false
    public var hasBeenPromptedForLifx = false
    
    public func askUserForLampToken() -> UIAlertController {
    
        let alert = UIAlertController(title: "LIFX Light",
                                      message: "Do you want to integrate our app with a LIFX light?",
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "LIFX API Token"
        }
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: { [weak self, weak alert] (_) in
            
            guard let strongSelf = self, let strongAlert = alert else {
                return
            }
            strongSelf.hasBeenPromptedForLifx = true
            UserDefaults.standard.setValue(strongSelf.LIFX_PromptedValue, forKey: strongSelf.LIFX_PromptedKey)
            
            if let text = strongAlert.textFields![0].text {
                UserDefaults.standard.setValue(text, forKey: strongSelf.LIFX_APIKey)
                strongSelf.hasLamp = true
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        return alert
    }
    
    public func updateAllLights(color: String, completion: @escaping (Bool) -> ()) {
        
        guard let lifxToken = UserDefaults.standard.value(forKey: self.LIFX_APIKey) as? String else {
            return
        }

        let loginString = String(format: "%@:%@", lifxToken, "")
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
            completion(false)
        }
        
        let config = URLSessionConfiguration.default
        let authString = "Basic \(base64LoginString)"
        config.httpAdditionalHeaders = ["Authorization" : authString]
        let session = URLSession(configuration: config)
        
        session.dataTask(with: request) { ( data, response, error) in
            if error != nil {
                print("Error occurred: \(String(describing: error))")
                completion(false)
            }
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let results = json["results"] as? [[String: Any]],
                    let status = results[0]["status"] as? String {
                    
                    if status == "ok" {
                        print("Lit up.")
                        completion(true)
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
                completion(false)
            }
        }.resume()
    }
}
