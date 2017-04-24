//
//  AddStoryViewController.swift
//  TechEmpathy
//
//  Created by Sarah Olson on 4/14/17.
//  Copyright © 2017 SarahEOlson. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseDatabase

class AddStoryViewController: UIViewController {

    var firebase: FIRDatabaseReference!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var storyTypeControl: UISegmentedControl!
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet weak var storyTextView: UITextView!
    @IBOutlet weak var audioTextField: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordOrWriteControl: UISegmentedControl!
    @IBOutlet weak var recordStack: UIStackView!
    @IBOutlet weak var writeStack: UIStackView!
    @IBOutlet weak var saveButton: UIButton!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var audioFilename: URL?
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)

        writeStack.isHidden = true
        //saveButton.isEnabled = false
        
        storyImageView.image = #imageLiteral(resourceName: "placeholder")
        
        // Get firebase reference
        firebase = FIRDatabase.database().reference()
        
        // Set up recording session
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [weak self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self?.recordButton.isEnabled = true
                    } else {
                        self?.recordButton.isEnabled = false
                    }
                }
            }
        } catch {
            print("Error setting up recording.")
            self.recordButton.isEnabled = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickColor" {
            let destinationVC = segue.destination as? ColorPickerViewController
            destinationVC?.colorPickerDelegate = self
        }
    }
    
    @IBAction func recordOrWriteChanged(_ sender: Any) {
        recordStack.isHidden = self.recordOrWriteControl.selectedSegmentIndex != 0
        writeStack.isHidden = self.recordOrWriteControl.selectedSegmentIndex != 1
        
        if !writeStack.isHidden {
            self.storyTextView.becomeFirstResponder()
        }
    }
    
    @IBAction func pickColor(_ sender: Any) {
        performSegue(withIdentifier: "PickColor", sender: self)
    }
    
    @IBAction func recordStory(_ sender: Any) {
        
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    @IBAction func saveStory(_ sender: Any) {
        if validateFields() {
            saveStoryData()
        }
    }
    
    func uploadAudio(story: Story, audioFile: URL) {
        
        // Create a reference to the file you want to upload
        let storageRef = FirebaseManager.sharedInstance.storiesStorage
        let riversRef = storageRef.child("audio/\(story.uuid).mp4")
        var downloadURL: URL? = nil
        
        _ = riversRef.putFile(audioFile, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading audio file: \(error)")
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                downloadURL = metadata!.downloadURL()
                var mutableStory = story
                mutableStory.audio = downloadURL?.absoluteURL.absoluteString
                
                let storiesRef = self.firebase.child("stories")
                storiesRef.updateChildValues(mutableStory.toJSON())
            }
        }
    }
    
    func validateFields() -> Bool {
        
//        if (colorTextField.text != nil) &&
//            (nicknameTextField.text != nil) &&
//            ((audioFilename != nil) || (storyTextView.text != nil)) {
//            
//            return true
//        }
//        return false
        return true
    }
    
    func saveStoryData() {

        let storiesRef = firebase.child("stories")
        let storyKey = firebase.childByAutoId().key
        
        let storyType: StoryType = storyTypeControl.selectedSegmentIndex == 0 ? .inclusion : .exclusion
        
        let newStory = Story(key: storyKey,
                             storyName: self.nicknameTextField.text ?? "",
                             user: FirebaseManager.sharedInstance.anonymousUser ?? "Anonymous iOS User",
                             color: colorTextField.text ?? "",
                             storyType: storyType,
                             audio: "",
                             storyText: storyTextView.text ?? "")
        storiesRef.updateChildValues(newStory.toJSON())
        
        if let audioFile = self.audioFilename {
            uploadAudio(story: newStory, audioFile: audioFile)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

extension AddStoryViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func startRecording() {
        
        self.audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        guard let filename = audioFilename else {
            return
        }
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordButton.setImage(#imageLiteral(resourceName: "recording"), for: .normal)
        } else {
            //TODO: display alert
            recordButton.setImage(#imageLiteral(resourceName: "microphone"), for: .normal)
        }
    }
    
    func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
}

extension AddStoryViewController: ColorPickerDelegate {
    
    func colorPicked(viewController: UIViewController, color: UIColor) {
        self.colorTextField.backgroundColor = color
        self.colorTextField.text = color.toHexString()
    }
}
