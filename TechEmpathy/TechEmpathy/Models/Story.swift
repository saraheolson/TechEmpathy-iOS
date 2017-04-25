//
//  Story.swift
//  TechEmpathy
//
//  Created by Sarah Olson on 4/15/17.
//  Copyright © 2017 SarahEOlson. All rights reserved.
//

import Foundation

enum StoryType: String {
    case exclusion = "exclusion"
    case inclusion = "inclusion"
    case all = "all"
}

struct JSONKeys {
    static let uuid = "uuid"
    static let dateAdded = "dateAdded"
    static let storyName = "storyName"
    static let user = "user"
    static let color = "color"
    static let storyType = "storyType"
    static let storyText = "storyText"
    static let isApproved = "isApproved"
    static let audio = "audio"
    static let image = "image"
}

struct Story {
    
    let key: String
    let uuid: String
    let dateAdded: Date
    var storyName: String
    var user: String
    var color: String
    var storyType: StoryType
    let isApproved: Bool
    var audio: String?
    var image: String?
    var storyText: String?
    var isLampLit = false
    
    /// Populating an existing story from JSON
    init?(key: String, JSON: [String: Any?]) {
        
        guard let nickname = JSON[JSONKeys.storyName] as? String,
              let user = JSON[JSONKeys.user] as? String,
              let color = JSON[JSONKeys.color] as? String,
              let storyTypeString = JSON[JSONKeys.storyType] as? String,
              let storyType = StoryType(rawValue: storyTypeString)
            else {
                return nil
        }
        self.key = key
        self.storyName = nickname
        self.user = user
        self.color = color
        self.storyType = storyType
        
        if let dateAddedString = JSON[JSONKeys.dateAdded] as? String,
           let dateAdded = Date.firebaseDate(fromString: dateAddedString) {
            self.dateAdded = dateAdded
        } else {
            self.dateAdded = Date()
        }
        
        if let uuid = JSON[JSONKeys.uuid] as? String {
            self.uuid = uuid
        } else {
            self.uuid = UUID().uuidString
        }
        if let approved = JSON[JSONKeys.isApproved] as? Bool {
            self.isApproved = approved
        } else {
            self.isApproved = false
        }
        if let audio = JSON[JSONKeys.audio] as? String {
            self.audio = audio
        }
        if let image = JSON[JSONKeys.image] as? String {
            self.image = image
        }
        if let storyText = JSON[JSONKeys.storyText] as? String {
            self.storyText = storyText
        }
    }
    
    /// Creating a new story
    init( key: String,
          storyName: String,
          user: String,
          color: String,
          storyType: StoryType,
          audio: String?,
          image: String?,
          storyText: String?) {
        
        self.key = key
        self.dateAdded = Date()
        self.storyName = storyName
        self.user = user
        self.color = color
        self.storyType = storyType
        self.audio = audio
        self.image = image
        self.storyText = storyText
        self.uuid = UUID().uuidString
        self.isApproved = false
    }
    
    func toJSON() -> [String: [String: Any]] {
        return [key :
            [JSONKeys.uuid: self.uuid,
             JSONKeys.dateAdded: self.dateAdded.firebaseDateString(),
             JSONKeys.storyName : self.storyName,
             JSONKeys.user: self.user,
             JSONKeys.color: self.color,
             JSONKeys.storyType: storyType.rawValue,
             JSONKeys.isApproved: self.isApproved,
             JSONKeys.audio: audio ?? "",
             JSONKeys.image: image ?? "",
             JSONKeys.storyText: storyText ?? ""]]
    }
}
