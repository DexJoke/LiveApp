//
//  ApiEditUser.swift
//  Greenlaundry
//
//  Created by Tùng Anh Nguyễn on 12/12/2020.
//

import Foundation
import Alamofire
import SwiftyJSON

class ApiEditUser: BaseAPI, APIDatasource {
    var name: String?
    var email: String?
    var address: String?
    var phoneNumber: String?
    var newPassword: String?
    var whatsapp: String!
    var kakaotalk: String!
    var city: String!
    
    init(email: String? = nil, address: String? = nil, phoneNumber: String? = nil, newPassword: String? = nil,
         whatsapp: String = "", kakaotalk: String = "", city: String = "") {
        self.address = address
        self.email = email
        self.newPassword = newPassword
        self.phoneNumber = phoneNumber
        self.whatsapp = whatsapp
        self.kakaotalk = kakaotalk
        self.city = city
    }
    
    func method() -> HTTPMethod {
        return .put
    }
    
    func api() -> String {
        return ApiUrl.EDIT_USER
    }
    
    func parameters() -> Parameters? {
        return [
            "email": email ?? "",
            "address": address ?? "",
            "phone_number": phoneNumber ?? "",
            "password" : newPassword ?? "",
            "cpassword" : newPassword ?? "",
            "whatsapp": whatsapp!,
            "kakaotalk": kakaotalk!,
            "city": city!
        ]
    }
    
    func paramEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    func isSecret() -> Bool {
        return true
    }
}
