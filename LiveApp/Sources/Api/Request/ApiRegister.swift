//
//  ApiRegister.swift
//  Greenlaundry
//
//  Created by Nguyễn Tùng Anh on 12/3/20.
//

import Foundation
import Alamofire

class ApiRegister : BaseAPI, APIDatasource {
    private var email: String!
    private var password: String!
    private var address: String!
    private var numberPhone: String!
    private var whatsapp: String!
    private var kakaotalk: String!
    private var city: String!
    
    init(email: String, password: String, address: String, numberPhone: String,
         whatsapp: String = "", kakaotalk: String = "", city: String = ""
    ) {
        self.email = email
        self.password = password
        self.address = address
        self.numberPhone = numberPhone
        self.whatsapp = whatsapp
        self.kakaotalk = kakaotalk
        self.city = city
    }
    
    func method() -> HTTPMethod {
        return .post
    }
    
    func api() -> String {
        return ApiUrl.API_REGISTER
    }
    
    func parameters() -> Parameters? {
        return [
            "email": email!,
            "password": password!,
            "phone": numberPhone!,
            "address": address!,
            "whatsapp": whatsapp!,
            "kakaotalk": kakaotalk!,
            "city": city!
        ]
    }
    
    func paramEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    func isSecret() -> Bool {
        return false
    }
}

