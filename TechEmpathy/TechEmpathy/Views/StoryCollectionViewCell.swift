//
//  StoryCollectionViewCell.swift
//  TechEmpathy
//
//  Created by Sarah Olson on 4/15/17.
//  Copyright © 2017 SarahEOlson. All rights reserved.
//

import UIKit
import AVFoundation

class StoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var listenButton: UIButton!
    
    var story: Story? {
        didSet {
            if let storyColor = story?.color {
                self.backgroundColor = UIColor(hexString: storyColor)
            }
            if story?.audio == nil || story?.audio == "No audio" {
                listenButton.tintColor = UIColor.gray
                listenButton.isEnabled = false
            } else {
                listenButton.tintColor = UIColor.white
                listenButton.isEnabled = true
            }
        }
    }
}
