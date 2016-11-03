//
//  SignUpViewController.swift
//  MessageApp
//
//  Created by John Vincent Riccione on 10/28/16.
//  Copyright © 2016 John Vincent Riccione. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    let imagePicker = UIImagePickerController()
    var selectedPhoto: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.selectPhoto(tap:)))
        tap.numberOfTapsRequired = 1
        profileImage.addGestureRecognizer(tap)
        
        profileImage.layer.cornerRadius = 128 / 2 //profileImage.frame.height / 2
        //print("Corner Radius is \(profileImage.layer.cornerRadius)")
        profileImage.clipsToBounds = true
        
    }
    
    func selectPhoto(tap: UITapGestureRecognizer) {
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePicker.sourceType = .camera
        }else {
            self.imagePicker.sourceType = .photoLibrary
        }
        
        self.present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func CancelDidTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SignUpDidTapped(_ sender: AnyObject) {
        
        if let email = emailTextField.text, let password = passwordTextField.text, let username = usernameTextField.text {
            
            var data = NSData()
            data = UIImageJPEGRepresentation(profileImage.image!, 0.1)! as NSData
            // Signing Up
            DataService.dataService.SignUp(username: username, email: email, password: password, data: data)
            
            
            
        }
        
    }

}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        selectedPhoto = info[UIImagePickerControllerEditedImage] as? UIImage
        self.profileImage.image = selectedPhoto
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}








