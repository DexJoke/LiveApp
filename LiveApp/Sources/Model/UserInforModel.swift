//
//  AuthenticateRequest.swift
//  livestream
//
//  Created by nguyen tung anh on 3/24/20.
//  Copyright © 2020 nguyen tung anh. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserInforModel: Codable {
    var id: String!
    var email: String!
    var userName: String!
    var token: String!
    var avatarUrl : String!
    
     init(json: JSON) {
        self.id = json["data"]["id"].stringValue
        self.email = json["data"]["email"].stringValue
        self.userName = json["data"]["username"].stringValue
        self.token = json["data"]["token"].stringValue
        self.avatarUrl = json["data"]["avatar_url"].stringValue
    }
}
