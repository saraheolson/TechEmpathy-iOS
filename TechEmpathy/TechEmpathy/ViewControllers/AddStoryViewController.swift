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

    @IBOutlet weak var storyNameTextField: UITextField!
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet weak var storyTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var storyTypeControl: UISegmentedControl!
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordOrWriteControl: UISegmentedControl!
    @IBOutlet weak var recordStack: UIStackView!
    @IBOutlet weak var writeStack: UIStackView!
    @IBOutlet weak var saveButton: UIButton!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var audioFilename: URL?
    
    let picker = UIImagePickerController()
    
    var errorText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Adjust view when keyboard is displayed
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)

        // Display audio and hide written story section
        writeStack.isHidden = true

        // Add gesture recognizer for image picker
        let imagePickerGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(displayImagePickerActionSheet))
        storyImageView.isUserInteractionEnabled = true
        storyImageView.addGestureRecognizer(imagePickerGestureRecognizer)
        
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
    
    // MARK: - Choosing an Image
    
    @IBAction func tappedSelectPhotoButton(_ sender: Any) {
        displayImagePickerActionSheet()
    }
    
    func displayImagePickerActionSheet() {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = UIColor(hexString: "#00414C")
        
        let cameraAction = UIAlertAction(title: "Camera",
                                         style: .default,
                                         handler: { [weak self] (alert:UIAlertAction!) -> Void in
            self?.takePhoto()
        })
        actionSheet.addAction(cameraAction)
        
        let libraryAction = UIAlertAction(title: "Photo Library",
                                          style: .default,
                                          handler: { [weak self] (alert:UIAlertAction!) -> Void in
            self?.selectPhotoFromLibrary()
        })
        actionSheet.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = UIImagePickerControllerSourceType.camera
            
            self.present(myPickerController, animated: true, completion: nil)
        } else {
            displayNoCameraAlert()
        }
    }
    
    func selectPhotoFromLibrary() {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    func displayNoCameraAlert(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "The camera on this device is unaccessible.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    // MARK: - Actions
    
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

        errorText = ""
        
        if isFormValid() {
            errorText = ""
            saveStoryData()
        } else {
            displayValidationAlert()
        }
    }
    
    // MARK: - Validation
    
    func isFormValid() -> Bool {
        return hasStoryName() && hasValidColor() && hasAStory()
    }
    
    func hasAStory() -> Bool {
        if hasStoryText() || audioFilename != nil {
            return true
        } else {
            errorText += "Either a written story or an audio recording is required. "
        }
        return false
    }
    
    func hasStoryText() -> Bool {
        if let storyText = storyTextView.text,
            !storyText.isEmpty{
            return true
        }
        return false
    }
    
    func hasStoryName() -> Bool {
        if let storyName = storyNameTextField.text,
            !storyName.isEmpty {
            return true
        } else {
            errorText += "Story Name is required. "
        }
        return false
    }
    
    func hasValidColor() -> Bool {
        if let color = colorTextField.text,
            !color.isEmpty {
            let hex_regex = "#([0-9A-F]{6})"
            if let _ = color.range(of: hex_regex, options: .regularExpression) {
                return true
            } else {
                errorText += "Color is required in hex format (example: #FFFFFF). "
            }
        } else {
            errorText += "Color is required. "
        }
        return false
    }
    
    func displayValidationAlert(){
        let alertVC = UIAlertController(
            title: "Missing Required Fields",
            message: errorText,
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }

    // MARK: - Saving and Uploading Data
    
    func saveStoryData() {

        let storiesRef = firebase.child("stories")
        let storyKey = firebase.childByAutoId().key
        
        let storyType: StoryType = storyTypeControl.selectedSegmentIndex == 0 ? .inclusion : .exclusion
        
        let newStory = Story(key: storyKey,
                             storyName: self.storyNameTextField.text ?? "",
                             user: FirebaseManager.sharedInstance.anonymousUser ?? "Anonymous iOS User",
                             color: colorTextField.text?.uppercased() ?? "",
                             storyType: storyType,
                             audio: "",
                             image: "",
                             storyText: storyTextView.text ?? "")
        storiesRef.updateChildValues(newStory.toJSON())
        
        if let audioFile = self.audioFilename {
            uploadAudio(story: newStory, audioFile: audioFile)
        }
        if let image = self.storyImageView.image {
            uploadImage(story: newStory, image: image)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func uploadAudio(story: Story, audioFile: URL) {
        
        // Create a reference to the file you want to upload
        let storageRef = FirebaseManager.sharedInstance.storiesStorage
        let audioRef = storageRef.child("audio/\(story.uuid).mp4")
        var downloadURL: URL? = nil
        
        _ = audioRef.putFile(audioFile, metadata: nil) { metadata, error in
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
    
    func uploadImage(story: Story, image: UIImage) {
        
        // Create a reference to the file you want to upload
        let storageRef = FirebaseManager.sharedInstance.storiesStorage
        let imagesRef = storageRef.child("images/\(story.uuid).jpg")
        var downloadURL: URL? = nil
        
        if let imageData = UIImageJPEGRepresentation(image, 0.8) {
        
            _ = imagesRef.put(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading umage: \(error)")
                } else {
                    downloadURL = metadata!.downloadURL()
                    var mutableStory = story
                    mutableStory.image = downloadURL?.absoluteURL.absoluteString
                    
                    let storiesRef = self.firebase.child("stories")
                    storiesRef.updateChildValues(mutableStory.toJSON())
                }
            }
        }
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
            recordButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
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
        self.colorTextField.text = color.toHexString().uppercased()
    }
}

extension AddStoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.storyImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
}
