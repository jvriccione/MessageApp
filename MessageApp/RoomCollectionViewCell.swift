//
//  RoomCollectionViewCell.swift
//  MessageApp
//
//  Created by John Vincent Riccione on 10/29/16.
//  Copyright © 2016 John Vincent Riccione. All rights reserved.
//

import UIKit
import FirebaseStorage
class RoomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailPhoto: UIImageView!
    @IBOutlet weak var captionLbl: UILabel!
    
    func configureCell(room: Room) {
        self.captionLbl.text = room.caption
        if let imageUrl = room.thumbnail {
            if imageUrl.hasPrefix("gs://") {
                FIRStorage.storage().reference(forURL: imageUrl).data(withMaxSize: INT64_MAX, completion: {
                    (data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    self.thumbnailPhoto.image = UIImage.init(data: data!)
                })
            }else if let url = NSURL(string: imageUrl), let data = NSData(contentsOf: url as URL) {
                self.thumbnailPhoto.image = UIImage.init(data: data as Data)
            }
        }
    }
    
}
