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
    @IBOutlet weak var lampButton: UIButton!
    
    var story: Story? {
        didSet {
            guard let story = story else {
                return
            }
            self.backgroundColor = UIColor(hexString: story.color)
            if story.audio == nil || story.audio == "" || story.audio == "No audio" {
                listenButton.tintColor = UIColor.gray
                listenButton.isEnabled = false
            } else {
                listenButton.tintColor = UIColor.white
                listenButton.isEnabled = true
            }
            storyImageView.pin_setPlaceholder(with: #imageLiteral(resourceName: "placeholder"))
            if let image = story.image,
                image != "" {
                storyImageView.pin_setImage(from: URL(string: image)!)
            } else {
                storyImageView.image = nil
            }
            self.lampButton.isHidden = !story.isLampLit
        }
    }
}
