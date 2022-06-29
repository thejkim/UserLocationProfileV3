//
//  UserProtileVC.swift
//  UserLocationProfile
//
//  Created by Joeun Kim on 6/11/22.
//

import UIKit
import Foundation
import AVFoundation

class UserProtileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImageBtn: UIButton!
    @IBOutlet weak var profileImageLoadingActivityIndicator: UIActivityIndicatorView!
    
    var imagePicker = UIImagePickerController()
    var currentProfileImageID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
                
        profileImageBtn.contentMode = .scaleAspectFill
        profileImageBtn.layer.cornerRadius = profileImageBtn.frame.width/2
        profileImageBtn.layer.masksToBounds = true
        profileImageBtn.layer.borderWidth = 2
        
//        profileImageLoadingActivityIndicator.hidesWhenStopped = true
        
        loadProfileImageIfAvailable()

    }
    
    func loadProfileImageIfAvailable() {
        let username = "test1" // TODO: properly get username
        
        // Using Custom Concurrent Dispatch Queue
        let dq = DispatchQueue(label: "test1", qos: .userInteractive, attributes: [.concurrent], autoreleaseFrequency: .workItem, target: nil)
        dq.async {
            JKLog.log(message: "\(Thread.current)") // MARK: global queue

            print("Loading image...")
            if let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first { // go to document directory
                
                let path = documentURL.path
                
                do {
                    let directoryContents = try FileManager.default.contentsOfDirectory(atPath: path)

                    // OR use .hasPrefix("\(username)")
                    if let targetFile = directoryContents.filter({ $0.contains("\(username)") }).first {
                        DispatchQueue.main.async { // in case loading image is slow, inform user it's loading
//                            self.profileImageBtn.setTitle("Loading...", for: .normal) // TODO: implement progress bar or activity indicator instead for better user experience
                            self.profileImageLoadingActivityIndicator.startAnimating()
                            self.profileImageLoadingActivityIndicator.isHidden = false

                        }
                        
                        print("target file found")
                        let targetFileURL = documentURL.appendingPathComponent(targetFile)
                        let image = UIImage(contentsOfFile: targetFileURL.path)
                        DispatchQueue.main.async {
                            sleep(5)

                            JKLog.log(message: "\(Thread.current)") // MARK: Main queue in global queue
                            self.profileImageLoadingActivityIndicator.stopAnimating()
                            self.profileImageLoadingActivityIndicator.isHidden = true
                            self.profileImageBtn.setBackgroundImage(image, for: .normal)
                            self.profileImageBtn.setTitle("", for: .normal)
                            print("image loaded!")


                        }
                        self.currentProfileImageID = targetFile
                    } else { // not found
                        DispatchQueue.main.async {
                            self.profileImageBtn.setTitle("", for: .normal)
                            self.profileImageLoadingActivityIndicator.isHidden = true
                        }
                    }
                    
                } catch {
                    JKLog.log(message: "catched!")
                }

            }
//            DispatchQueue.main.async {
//                self.profileImageBtn.setTitle("", for: .normal)
//            }

        } // end of subthread
        
        /* // Using Global Dispatch Queue
        DispatchQueue.global(qos: .userInteractive).async {
            JKLog.log(message: "\(Thread.current)") // MARK: global queue

            print("Loading image...")
            if let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first { // go to document directory
                let path = documentURL.path
                do {
                    let directoryContents = try FileManager.default.contentsOfDirectory(atPath: path)

                    // OR use .hasPrefix("\(username)")
                    if let targetFile = directoryContents.filter({ $0.contains("\(username)") }).first {
                        print("target file found")
                        let targetFileURL = documentURL.appendingPathComponent(targetFile)
                        let image = UIImage(contentsOfFile: targetFileURL.path)
                        DispatchQueue.main.async {
                            JKLog.log(message: "\(Thread.current)") // MARK: Main queue in global queue
                            
                            self.profileImageBtn.setBackgroundImage(image, for: .normal)
                            self.profileImageBtn.setTitle("", for: .normal)
                            print("image loaded!")


                        }
                        self.currentProfileImageID = targetFile
                    }
                    
                } catch {
                    
                }

            }
//            DispatchQueue.main.async {
//                self.profileImageBtn.setTitle("", for: .normal)
//            }

        } // end of subthread
        */
        
    }
    

    // Set or Update profile image
    @IBAction func profileImageBtnTouched(_ sender: UIButton) {
        let currentUsername = "test1" // TODO: properly get current username
        
        let alertDialog = UIAlertController(title: "Profile Image", message: "If you want to take a new photo, select Open Camera to open your camera. If you want to choose a photo from photo gallery, select Open Gallery to choose an existing photo.", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Open Camera", style: .default, handler: { (action) in
            self.openCamera()
        })
        let gallery = UIAlertAction(title: "Open Gallery", style: .default, handler: { (action) in
            self.openGallery()
        })
        let delete = UIAlertAction(title: "Delete", style: .default, handler: { (action) in
            // Reset background image of the btn
            self.profileImageBtn.setBackgroundImage(UIImage(systemName: "person.fill.questionmark"), for: .normal)

            // Remove from Core Data, document directory
            DispatchQueue.global(qos: .background).async {
                CoreDataManager.sharedManager.removeUserProfileImageID(fromUser: currentUsername)
                guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                self.removeFileFrom(url: documentURL, forUser: currentUsername)
            }

            
        } )
        alertDialog.addAction(camera)
        alertDialog.addAction(gallery)
        alertDialog.addAction(delete)
        present(alertDialog, animated: true, completion: nil)
        
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Camera Not Available", message: "Cannot open Camera. Please choose image from Photo Gallery instead.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        imagePicker.sourceType = .photoLibrary // .camera //.savedPhotosAlbum(where taken photo added to)
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        JKLog.log(message: "vc shown")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("info type = \(type(of: info))")
        print("image picked: \(info[.originalImage])") // cropRect, editedImage, livePhoto, originalImage
        
        guard let chosenImage = info[.originalImage] as? UIImage else {
            return
        }
        
        profileImageBtn.setBackgroundImage(chosenImage, for: .normal)
        
        let currentUsername = "test1" // TODO: properly get current username
        let imageIDString = "\(currentUsername)_\(Date())"

        DispatchQueue.global(qos: .utility).async { //
            JKLog.log(message: "\(Thread.current)") // MARK: global queue

            // SAVE INTO COREDATA
            print("Saving image...")
            if CoreDataManager.sharedManager.saveUserProfileImageID(forUser: currentUsername, withImage: imageIDString) { // error point
                guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                
                // REMOVE OLD IMAGE FROM DOCUMENT DIRECTORY
                self.removeFileFrom(url: documentURL, forUser: currentUsername)
                
                // SAVE SELECTED IMAGE INTO DOCUMENT DIRECTORY
                let outputFileURL = documentURL.appendingPathComponent("\(imageIDString).jpg")
                
                if let imageData = chosenImage.jpegData(compressionQuality: 1) {
                    do {
                        try imageData.write(to: outputFileURL)
                        print("\(outputFileURL)")
                    } catch {
                        
                    }
                } else {
                    print("Failed to image -> data")
                }
                
            }
            print("profile image saved!!")
        } // end of subthread
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: remove file
    func removeFileFrom(url: URL, forUser: String) {
        JKLog.log(message: "\(Thread.current)")
        let path = url.path
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(atPath: path)

            if let targetFile = directoryContents.filter({ $0.contains("\(forUser)") }).first {
                let targetFileURL = url.appendingPathComponent(targetFile)
                try FileManager.default.removeItem(at: targetFileURL)
                
            }
            
        } catch {
            print("Failed to delete old image file")
        }

    }
    
    @IBAction func btnTouched(_ sender: UIButton) {
        print("btn touched!")
    }
    
    
    
}
