//
//  ChatTextModel.swift
//  livestream
//
//  Created by DaoVanSon on 3/26/20.
//  Copyright © 2020 nguyen tung anh. All rights reserved.
//

import UIKit
import SwiftyJSON

enum ChatType: Int {
    case Like
    case Point
    case Message
}

class ChatTextModel {
    var type: ChatType!
    var message: String!
    var avatar: String!
    
    required init(json: JSON) {
        self.message = json["value"].stringValue
        self.type = ChatType(rawValue: json["type"].intValue)
        self.avatar = json["avatar_url"].stringValue
    }
}
