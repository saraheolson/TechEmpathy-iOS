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
    
    @IBOutlet weak var storyNameLabel: UILabel!
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var lampButton: UIButton!
    
    var story: Story? {
        didSet {

            resetCell()
            
            guard let story = story else {
                return
            }
            if story.isApproved {
                
                storyNameLabel.text = story.storyName
                
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
            } else {
                
                self.backgroundColor = UIColor(hexString: "#F1F1F1")
                
                self.storyNameLabel.text = "This story has not yet been approved."

                listenButton.tintColor = UIColor.gray
                listenButton.isEnabled = false
            }
        }
    }
    
    func resetCell() {
        storyImageView.image = nil
        self.lampButton.isHidden = true
        self.storyNameLabel.text = ""
        self.listenButton.isEnabled = false
        self.listenButton.tintColor = UIColor.gray
    }
}
