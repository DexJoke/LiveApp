//
//  ApiForgotPawword.swift
//  Greenlaundry
//
//  Created by Tùng Anh Nguyễn on 06/12/2020.
//

import Foundation
import SwiftyJSON
import Alamofire

class ApiForgotPawword: BaseAPI, APIDatasource {
    private var email: String!
    
    init(email: String) {
        self.email = email
    }
    
    func method() -> HTTPMethod {
        return .post
    }
    
    func api() -> String {
        return ApiUrl.API_FORGOT_PASSWORD
    }
    
    func parameters() -> Parameters? {
        return [
            "email": email!
        ]
    }
    
    func paramEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    func isSecret() -> Bool {
        return false
    }
}
