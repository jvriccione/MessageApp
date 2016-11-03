//
//  ChatTableViewCell.swift
//  MessageApp
//
//  Created by John Vincent Riccione on 10/30/16.
//  Copyright © 2016 John Vincent Riccione. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import Firebase
class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var messageTextView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 50 / 2 //profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }
    
    func configCell(idUser: String, message: Dictionary<String, AnyObject>) {
        self.messageTextLabel.text = message["message"] as? String
        self.messageTextLabel.numberOfLines = 100
        self.messageTextLabel.sizeToFit()
        
        DataService.dataService.PEOPLE_REF.child(idUser).observe(.value, with: {
            snapshot -> Void in
            let dict = snapshot.value as! Dictionary<String, AnyObject>
            let imageUrl = dict["profileImage"] as! String
            if imageUrl.hasPrefix("gs://") {
                FIRStorage.storage().reference(forURL: imageUrl).data(withMaxSize: INT64_MAX, completion: { (data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    self.profileImageView.image = UIImage.init(data: data!)
                })
            }
        })
    }

}
