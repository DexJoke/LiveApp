//
//  ErrorResponse.swift
//  livestream
//
//  Created by DaoVanSon on 3/10/20.
//  Copyright © 2020 nguyen tung anh. All rights reserved.
//

import UIKit
import SwiftyJSON

class ErrorResponse {
    var documentationUrl: String?
    var message: String?
    
    init(json: JSON) {
        print("Error:\(json)")
        documentationUrl = json["documentation_url"].stringValue
        message = json["message"].stringValue
    }
}

