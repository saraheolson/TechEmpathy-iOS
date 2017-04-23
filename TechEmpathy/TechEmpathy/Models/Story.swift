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

struct Story {
    
    let key: String
    let uuid: String
    let dateAdded: String
    var storyName: String
    var user: String
    var color: String
    var storyType: StoryType
    var audio: String?
    var storyText: String?
    var isLampLit = false
    
    init?(key: String, JSON: [String: Any?]) {
        
        guard let nickname = JSON["storyName"] as? String,
              let user = JSON["user"] as? String,
              let color = JSON["color"] as? String,
              let storyTypeString = JSON["storyType"] as? String,
              let storyType = StoryType(rawValue: storyTypeString)
            else {
                return nil
        }
        self.key = key
        self.uuid = UUID().uuidString
        self.dateAdded = "\(Date())"
        self.storyName = nickname
        self.user = user
        self.color = color
        self.storyType = storyType
        
        if let audio = JSON["audio"] as? String {
            self.audio = audio
        }
        if let storyText = JSON["storyText"] as? String {
            self.storyText = storyText
        }
    }
    
    init( key: String,
          storyName: String,
          user: String,
          color: String,
          storyType: StoryType,
          audio: String?,
          storyText: String?) {
        
        self.key = key
        self.uuid = UUID().uuidString
        self.dateAdded = "\(Date())"
        self.storyName = storyName
        self.user = user
        self.color = color
        self.storyType = storyType
        self.audio = audio
        self.storyText = storyText
    }
    
    func toJSON() -> [String: [String: Any]] {
        return ["\(key)" : ["uuid": self.uuid,
                 "dateAdded": self.dateAdded,
                 "storyName" : self.storyName,
                 "user": self.user,
                 "color": self.color,
                 "storyType": storyType.rawValue,
                 "audio": audio ?? "",
                 "storyText": storyText ?? ""]]
    }
}
