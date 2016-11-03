//
//  Room.swift
//  MessageApp
//
//  Created by John Vincent Riccione on 10/29/16.
//  Copyright © 2016 John Vincent Riccione. All rights reserved.
//

import Foundation
import UIKit
class Room {
    var caption: String!
    var thumbnail: String!
    var id: String!
    
    init(key: String, snapshot: Dictionary<String, AnyObject>) {
        self.id = key
        self.caption = snapshot["caption"] as! String
        self.thumbnail = snapshot["thumbnailUrlFromStorage"] as! String
    }
}
