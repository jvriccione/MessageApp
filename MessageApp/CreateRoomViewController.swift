//
//  CreateRoomViewController.swift
//  MessageApp
//
//  Created by John Vincent Riccione on 10/28/16.
//  Copyright © 2016 John Vincent Riccione. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateRoomViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var choosePhotoBtn: UIButton!
    @IBOutlet weak var captionLbl: UITextField!
    @IBOutlet weak var photoImg: UIImageView!
    
    var selectedPhoto: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(CreateRoomViewController.dismissKeyboard(tap:)))
        dismissKeyboard.numberOfTapsRequired = 1
        view.addGestureRecognizer(dismissKeyboard)
        // Do any additional setup after loading the view.
    }
    func dismissKeyboard(tap: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func CancelDidTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectPhoto_Didtapped(_ sender: AnyObject) {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        selectedPhoto = info[UIImagePickerControllerEditedImage] as? UIImage
        photoImg.image = selectedPhoto
        picker.dismiss(animated: true, completion: nil)
        choosePhotoBtn.isHidden = true
    }
    @IBAction func CreateRoomDidTapped(_ sender: AnyObject) {
        
        var data: NSData = NSData()
        data = UIImageJPEGRepresentation(photoImg.image!, 0.1)! as NSData
        DataService.dataService.CreateNewRoom(user: FIRAuth.auth()!.currentUser!, caption: captionLbl.text!, data: data)
        dismiss(animated: true, completion: nil)
    }

}
