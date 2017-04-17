//
//  FirebaseManager.swift
//  TechEmpathy
//
//  Created by Sarah Olson on 4/15/17.
//  Copyright © 2017 SarahEOlson. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class FirebaseManager {
    
    static let sharedInstance = FirebaseManager()
    
    private init() { }
    
    // Get firebase reference
    var firebaseRef = FIRDatabase.database().reference()

//    var storageRef = FIRStorage.storage().reference()
    var storiesStorage = FIRStorage.storage().reference().child("stories")
    
    var anonymousUser: String? = nil
    
    func authenticate() {
        FIRAuth.auth()?.signInAnonymously() { (user, error) in
            self.anonymousUser = user?.uid
        }
    }
}
