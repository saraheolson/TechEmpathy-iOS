//
//  Date+Format.swift
//  TechEmpathy
//
//  Created by Sarah Olson on 4/23/17.
//  Copyright © 2017 SarahEOlson. All rights reserved.
//

import Foundation

let firebaseDateFormatter = DateFormatter()

extension Date {

    //Create a Date from a string like "2017-04-17 14:45:09 +0000"
    static func firebaseDate(fromString dateString: String) -> Date? {
        
        firebaseDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return firebaseDateFormatter.date(from: dateString)
    }
    
    func firebaseDateString() -> String {
        
        firebaseDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return firebaseDateFormatter.string(from: self)
    }
}
