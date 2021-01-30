//
//  ApiCheckCoupons.swift
//  Greenlaundry
//
//  Created by Tùng Anh Nguyễn on 13/12/2020.
//

import Foundation
import Alamofire
import SwiftyJSON

class ApiCheckCoupons: BaseAPI, APIDatasource {
    private var code: String!
    
    init(code: String) {
        self.code = code
    }
    
    func method() -> HTTPMethod {
        return .get
    }
    
    func api() -> String {
        return ApiUrl.CHECK_COUPOUNS + "/\(code!)"
    }
    
    func parameters() -> Parameters? {
        return nil
    }
    
    func paramEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    func isSecret() -> Bool {
        return true
    }
}
