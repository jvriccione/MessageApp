//
//  DataService.swift
//  MessageApp
//
//  Created by John Vincent Riccione on 10/29/16.
//  Copyright © 2016 John Vincent Riccione. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

let roofRef = FIRDatabase.database().reference()

class DataService {
    
    static let dataService = DataService()
    
    private var _BASE_REF = roofRef
    private var _ROOM_REF = roofRef.child("rooms")
    private var _MESSAGE_REF = roofRef.child("messages")
    private var _PEOPLE_REF = roofRef.child("people")
    
    var currentUser: FIRUser? {
        return FIRAuth.auth()!.currentUser!
    }
    
    var BASE_REF: FIRDatabaseReference {
        return _BASE_REF
    }
    var ROOM_REF: FIRDatabaseReference {
        return _ROOM_REF
    }
    var MESSAGE_REF: FIRDatabaseReference {
        return _MESSAGE_REF
    }
    var PEOPLE_REF: FIRDatabaseReference {
        return _PEOPLE_REF
    }
    var storageRef: FIRStorageReference {
        return FIRStorage.storage().reference()
    }
    
    var fileUrl: String!
    
    func CreateNewRoom(user: FIRUser, caption: String, data: NSData) {
        let filePath = "\(user.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate))"
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.child(filePath).put(data as Data, metadata: metaData) { (metadata, error) in
            if let error = error {
                print("Error uploading: \(error.localizedDescription)")
                return
            }
            // Create a url for data(thumbnail image)
            print(metadata)
            let newFileUrl = metadata!.downloadURLs![0].absoluteString
            //self.fileUrl = metadata!.downloadURLs![0].absoluteString
            
            if let user = FIRAuth.auth()?.currentUser {
                let idRoom = self.BASE_REF.child("rooms").childByAutoId()
                idRoom.setValue(["caption": caption, "thumbnailUrlFromStorage": self.storageRef.child(metadata!.path!).description, "fileUrl": newFileUrl])
                    self.PEOPLE_REF.child(user.uid).child("myrooms").child(idRoom.key).setValue(true)
            }
        }
    }
    
    /*func fetchDataFromServer(callback: @escaping (Room) -> ()) {
        DataService.dataService.ROOM_REF.observe(.childAdded, with: { (snapshot) in
            let room = Room(key: snapshot.key, snapshot: snapshot.value as! Dictionary<String, AnyObject>)
            callback(room)
        })
    }*/
    
    // Sign Up
    func SignUp(username: String, email: String, password: String, data: NSData) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let changeRequest = user?.profileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges(completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            })
            let filePath = "profileImage/\(user!.uid)"
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            self.storageRef.child(filePath).put(data as Data, metadata: metadata, completion: { (metadata, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.fileUrl = metadata?.downloadURLs![0].absoluteString
                let changeRequestPhoto = user!.profileChangeRequest()
                changeRequestPhoto.photoURL = URL(string: self.fileUrl)
                changeRequestPhoto.commitChanges(completion: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }else {
                        print("profile updated")
                    }
                })
                self.PEOPLE_REF.child((user?.uid)!).setValue(["username": username, "email": email, "profileImage": self.storageRef.child((metadata?.path)!).description])
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            })
        })
    }
    
    // Implement LogIn Func
    
    func logIn(email: String, password: String) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.login()
        })
    }
    
    func logout() {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let logInVC = storyboard.instantiateViewController(withIdentifier: "LogInVC")
            UIApplication.shared.keyWindow?.rootViewController = logInVC
        }catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    //  Update profile
    
    func SaveProfile(username: String, email: String, data: Data) {
        let user = FIRAuth.auth()?.currentUser!
        let filePath = "\(user!.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate))"
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        self.storageRef.child(filePath).put(data, metadata: metaData) { (metadata, error) in
            if let error = error {
                print("Error uploading: \(error.localizedDescription)")
                return
            }
            self.fileUrl = metadata!.downloadURLs![0].absoluteString
            let changeRequestProfile = user?.profileChangeRequest()
            changeRequestProfile?.photoURL = URL(string: self.fileUrl)
            changeRequestProfile?.displayName = username
            changeRequestProfile?.commitChanges(completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }else {
                    
                }
            })
            if let user = user {
                user.updateEmail(email, completion: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }else {
                        print("email update")
                    }
                })
            }
        }
    }
    
    func CreateNewMessage(userId: String, roomId: String, content: String, textMessage: String) {
        let idMessage = roofRef.child("messages").childByAutoId()
        DataService.dataService.MESSAGE_REF.child(idMessage.key).setValue(["message": content, "senderId": userId])
        DataService.dataService.ROOM_REF.child(roomId).child("messages").child(idMessage.key).setValue(true)
    }
    
    func fetchMessageFromServer(roomId: String, callback: @escaping (FIRDataSnapshot) -> ()) {
        DataService.dataService.ROOM_REF.child(roomId).child("messages").observe(.childAdded, with: {snapshot -> Void in
            DataService.dataService.MESSAGE_REF.child(snapshot.key).observe(.value, with: {snap -> Void in
                callback(snap)
            })
        })
    }
    
}
