//
//  ProfileTableViewController.swift
//  MessageApp
//
//  Created by John Vincent Riccione on 10/28/16.
//  Copyright © 2016 John Vincent Riccione. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Profile"
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.selectPhoto(tap:)))
        tap.numberOfTapsRequired = 1
        profileImage.addGestureRecognizer(tap)
        profileImage.layer.cornerRadius = 80 / 2 //profileImage.frame.size.height / 2
        profileImage.clipsToBounds = true
        
        if let user = DataService.dataService.currentUser {
            username.text = user.displayName
            email.text = user.email
            if user.photoURL != nil {
                if let data = NSData(contentsOf: user.photoURL!) {
                    self.profileImage!.image = UIImage.init(data: data as Data)

                }
            }
        }else {
            // No user is signed in
        }
    }
    
    func selectPhoto(tap: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        }else {
            imagePicker.sourceType = .photoLibrary
        }
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    // imagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profileImage.image = info[UIImagePickerControllerEditedImage] as! UIImage
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveDidTapped(_ sender: AnyObject) {
        var data = Data()
        data = UIImageJPEGRepresentation(profileImage.image!, 0.1)!
        DataService.dataService.SaveProfile(username: username.text!, email: email.text!, data: data)
    }
}
