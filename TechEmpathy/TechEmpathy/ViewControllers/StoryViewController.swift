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

protocol StoryDataDelegate {
    func storyDataChanged(datasource: [Story])
}

class StoryViewController: UIViewController {

    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet weak var storyTypeControl: UISegmentedControl!
    
    fileprivate var datasource: [Story] = []
    private var storyDatasource = StoryDatasource()
    var audioPlayer: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.register(UINib(nibName: "StoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Story")

        storyDatasource.delegate = self
        
        // LIFX integration
        if !LIFXManager.sharedInstance.hasBeenPromptedForLifx {
            self.present(LIFXManager.sharedInstance.askUserForLampToken(), animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        storyDatasource.retrieveData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        storyDatasource.removeObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    @IBAction func storyTypeChanged(_ sender: Any) {
        switch (storyTypeControl.selectedSegmentIndex) {
        case 1:
            datasource = storyDatasource.getDatasourceForFilter(storyType: .inclusion)
        case 2:
            datasource = storyDatasource.getDatasourceForFilter(storyType: .exclusion)
        default:
            datasource = storyDatasource.getDatasourceForFilter(storyType: .all)
        }
        collectionView.reloadData()
    }
    
    private class StoryDatasource {
        
        var currentDataSource: [Story] = []
        var delegate: StoryViewController?
        var firebaseRef : FIRDatabaseReference? = nil
        
        func retrieveData() {
            
            firebaseRef = FirebaseManager.sharedInstance.firebaseRef
            guard let ref = firebaseRef else {
                return
            }

            let storiesQuery = ref.child("stories")
                .queryOrdered(byChild: "dateAdded")
                .queryLimited(toLast: 20)
            
            let _ = storiesQuery.observe(.value, with: { (snapshot) in
                if let JSON = snapshot.value as? [String: [String: Any]] {
                    
                    let storiesArray: [Story] = JSON.flatMap{ (story) in
                        return Story(key: story.key, JSON: story.value)
                        }
                    self.currentDataSource = storiesArray
                    self.delegate?.storyDataChanged(datasource: self.currentDataSource)
                }
            })
        }
        
        func getDatasourceForFilter(storyType: StoryType) -> [Story] {
            switch (storyType) {
            case .exclusion:
                return currentDataSource.filter { $0.storyType == .exclusion }
            case .inclusion:
                return currentDataSource.filter { $0.storyType == .inclusion }
            default:
                return currentDataSource
            }
        }
        
        func removeObservers() {
            firebaseRef?.removeAllObservers()
        }
    }
}

extension StoryViewController: StoryDataDelegate {
    func storyDataChanged(datasource: [Story]) {
        self.datasource = datasource
        self.storyTypeControl.selectedSegmentIndex = 0
        self.collectionView.reloadData()
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
        LIFXManager.sharedInstance.updateAllLights(color: story.color) { [weak self] (success) in
            if success {
                DispatchQueue.main.async {
                    guard let stories = self?.datasource else {
                        return
                    }
                    let litStory = self?.datasource[indexPath.row]
                    
                    self?.datasource = stories.map { (story) in
                        var mutableStory = story
                        if let selectedStory = litStory,
                            mutableStory.key == selectedStory.key {
                            mutableStory.isLampLit = true
                            //print("I saw the light")
                        } else {
                            mutableStory.isLampLit = false
                            //print("So not lit")
                        }
                        return mutableStory
                    }
                    self?.collectionView.reloadData()
                }
            }
        }
    }
}
