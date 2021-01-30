//
//  TokenModel.swift
//  livestream
//
//  Created by nguyen tung anh on 3/11/20.
//  Copyright © 2020 nguyen tung anh. All rights reserved.
//

import UIKit
import SwiftyJSON

class TokenModel {
    var identity: String!
    var token: String!
    var roomName: String!
    var hostUserName: String?
    var hostAvatar: String?
//    var participants : [String] = []
    
    required init(json: JSON) {
        self.identity = json["identity"].stringValue
        self.token = json["token"].stringValue
//        self.participants = (json["participants"].arrayObject as? [String])!
        self.hostUserName = json["host"]["username"].stringValue
        self.hostAvatar = json["host"]["avatar_url"].stringValue
    }
    
   required init(userName: String, token: String, roomName: String) {
        self.identity = userName
        self.token = token
        self.roomName = roomName
    }
    
}
