//
//  StoryViewController.swift
//  TechEmpathy
//
//  Created by Sarah Olson on 4/15/17.
//  Copyright © 2017 SarahEOlson. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseDatabase

class StoryViewController: UIViewController {

    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet weak var storyTypeControl: UISegmentedControl!
    
    fileprivate var datasource: [Story] = []
    var audioPlayer: AVPlayer?
    var firebaseRef: FIRDatabaseReference?
    var storiesQuery: FIRDatabaseQuery?
    var queryHandle: UInt?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firebaseRef = FirebaseManager.sharedInstance.firebaseRef
        
        self.collectionView.register(UINib(nibName: "StoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Story")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        storiesQuery = (firebaseRef!.child("stories")
            .queryOrdered(byChild: "dateAdded")
            .queryLimited(toLast: 20))
        updateQuery()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    @IBAction func storyTypeChanged(_ sender: Any) {
    }
    
    func updateQuery() {
        queryHandle = storiesQuery?.observe(.value, with: { (snapshot) in
            if let JSON = snapshot.value as? [String: [String: Any]] {
                
                let storiesArray: [Story] = JSON.flatMap{ (story) in
                    return Story(key: story.key, JSON: story.value)
                }
                self.datasource = storiesArray
                self.collectionView.reloadData()
            }
        })
    }
}

extension StoryViewController: UICollectionViewDataSource {
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Story", for: indexPath) as! StoryCollectionViewCell
        cell.story = datasource[indexPath.row]
        return cell
    }
}

extension StoryViewController: UICollectionViewDelegate {
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let story = datasource[indexPath.row]
        if let audio = story.audio {
            if let audioURL = URL(string: audio) {
                let playerItem = AVPlayerItem(url: audioURL)
                audioPlayer = AVPlayer(playerItem:playerItem)
                self.audioPlayer?.play()
            }
        }
    }
}

