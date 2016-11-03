//
//  LoginViewController.swift
//  MessageApp
//
//  Created by John Vincent Riccione on 10/28/16.
//  Copyright © 2016 John Vincent Riccione. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(CreateRoomViewController.dismissKeyboard(tap:)))
        dismissKeyboard.numberOfTapsRequired = 1
        view.addGestureRecognizer(dismissKeyboard)
    }
    func dismissKeyboard(tap: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func logInDidTapped(_ sender: AnyObject) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            DataService.dataService.logIn(email: email, password: password)
        }
        
    }
    
}
