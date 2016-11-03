//
//  ChatViewController.swift
//  MessageApp
//
//  Created by John Vincent Riccione on 10/28/16.
//  Copyright © 2016 John Vincent Riccione. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

private struct Constants {
    static let cellIdMessageRecieved = "MessageCellYou"
    static let cellIdMessageSent = "MessageCellMe"
}

class ChatViewController: UIViewController, UITextFieldDelegate {

    var roomId: String!
    var messages: [FIRDataSnapshot] = []
    var rooms = [Room]()
    
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(roomId)
        DataService.dataService.ROOM_REF.observe(.childAdded, with: { (snapshot) -> Void in
            let room = Room(key: snapshot.key, snapshot: snapshot.value as! Dictionary<String, AnyObject>)
            self.rooms.append(room)
            self.title = room.caption
        })
        DataService.dataService.fetchMessageFromServer(roomId: roomId) { (snap) in
            self.messages.append(snap)
            print(self.messages)
            self.tableView.reloadData()
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.showOrHideKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.showOrHideKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)

    }
    
    // UITextField delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
    func showOrHideKeyboard(notification: NSNotification) {
        if let keyboardInfo: Dictionary = notification.userInfo {
            if notification.name == NSNotification.Name.UIKeyboardWillShow {
                UIView.animate(withDuration: 1, animations: { () in
                    self.constraintToBottom.constant = (keyboardInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
                    self.view.layoutIfNeeded()
                }) { (completed: Bool) -> Void in
                    // move to the last message
                    self.moveToLastMessage()
                }
            }else if notification.name == NSNotification.Name.UIKeyboardWillHide {
                UIView.animate(withDuration: 1, animations: { () in
                    self.constraintToBottom.constant = 0
                }) { (completed: Bool) -> Void in
                    // move to the last message
                    self.moveToLastMessage()

                }
            }
        }
    }
    
    func moveToLastMessage() {
        if self.tableView.contentSize.height > self.tableView.frame.height {
            let contentOfSet = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.height)
            self.tableView.setContentOffset(contentOfSet, animated: true)
        }
    }
    
    @IBAction func SendButtonDidTapped(_ sender: AnyObject) {
        self.chatTextField.resignFirstResponder()
        if chatTextField.hasText {
            if let user = FIRAuth.auth()?.currentUser {
                DataService.dataService.CreateNewMessage(userId: user.uid, roomId: roomId, content: chatTextField.text!, textMessage: chatTextField.text!)
            }else {
                // No user is signed in
            }
            self.chatTextField.text = nil
        }else {
            print("error: Empty String")
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageSnapshot = messages[indexPath.row]
        let message = messageSnapshot.value as! Dictionary<String, AnyObject>
        let messageId = message["senderId"] as! String
        //let messageSize = NSString
        if messageId == DataService.dataService.currentUser?.uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdMessageSent, for: indexPath) as! ChatTableViewCell
            cell.updateConstraintsIfNeeded()
            cell.configCell(idUser: messageId, message: message)
            self.tableView.estimatedRowHeight = 100
            self.tableView.rowHeight = UITableViewAutomaticDimension
            //self.tableView.rowHeight += 10
            print("Height of cell is \(self.tableView.rowHeight)")
            print("Frame.height is \(self.tableView.frame.size.height)")

            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdMessageRecieved, for: indexPath) as! ChatTableViewCell
            cell.configCell(idUser: messageId, message: message)
            self.tableView.estimatedRowHeight = 100
            self.tableView.rowHeight = UITableViewAutomaticDimension
            //self.tableView.rowHeight += 10
            print("Height of cell is \(self.tableView.rowHeight)")
            print("Frame.height is \(self.tableView.frame.size.height)")
        
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = self.tableView.rowHeight
        print("Height of cell is \(height)")
        if height <= 55 {
            return 55
        }else {
            return height
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let messageSnapshot = messages[indexPath.row]
        let message = messageSnapshot.value as! Dictionary<String, AnyObject>
        let messageId = message["senderId"] as! String
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        if messageId == DataService.dataService.currentUser?.uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdMessageSent, for: indexPath) as! ChatTableViewCell
            cell.updateConstraintsIfNeeded()
            cell.configCell(idUser: messageId, message: message)
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            cell.bounds = CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            let height = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height + 1
            return height
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdMessageRecieved, for: indexPath) as! ChatTableViewCell
            cell.configCell(idUser: messageId, message: message)
            cell.updateConstraintsIfNeeded()
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            cell.bounds = CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            let height = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height + 1
            return height
        }

    }*/
    
}
