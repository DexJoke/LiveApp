//
//  ApiRequestGetOrders.swift
//  Greenlaundry
//
//  Created by Tùng Anh Nguyễn on 15/12/2020.
//

import Foundation
import SwiftyJSON
import Alamofire

class ApiGetOrders: BaseAPI, APIDatasource {
    func method() -> HTTPMethod {
        return .get
    }
    
    func api() -> String {
        return ApiUrl.GET_ORDERS
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
