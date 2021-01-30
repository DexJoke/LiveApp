//
//  ApiAddDeviceToken.swift
//  Greenlaundry
//
//  Created by Tùng Anh Nguyễn on 26/12/2020.
//

import Foundation
import SwiftyJSON
import Alamofire

class ApiAddDeviceToken: BaseAPI, APIDatasource {
    private var deviceToken: String!
    
    init(token: String) {
        deviceToken = token
    }
    
    func method() -> HTTPMethod {
        return .post
    }
    
    func api() -> String {
        return ApiUrl.ADD_TOKEN_DEVICE
    }
    
    func parameters() -> Parameters? {
        return [
            "device_token": deviceToken!,
            "device_type": "ios"
        ]
    }
    
    func paramEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    func isSecret() -> Bool {
        return true
    }
}
