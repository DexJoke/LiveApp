//
//  ApiLogin.swift
//  Greenlaundry
//
//  Created by Nguyễn Tùng Anh on 12/2/20.
//

import Foundation
import Alamofire
import SwiftyJSON

class ApiLogin : BaseAPI, APIDatasource {
    private var email: String!
    private var password: String!
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    func method() -> HTTPMethod {
        return .post
    }
    
    func api() -> String {
        return ApiUrl.API_LOGIN
    }
    
    func parameters() -> Parameters? {
        return [
            "email": email!,
            "password": password!
        ]
    }
    
    func paramEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    func isSecret() -> Bool {
        return false
    }
}
