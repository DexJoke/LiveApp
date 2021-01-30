//
//  ApiCreateOrder.swift
//  Greenlaundry
//
//  Created by Tùng Anh Nguyễn on 09/12/2020.
//

import Foundation
import Alamofire
import SwiftyJSON

class ApiCreateOrder: BaseAPI, APIDatasource {
    private var order: Order!
    
    init(order: Order) {
        self.order = order
    }
    
    func method() -> HTTPMethod {
        .post
    }
    
    func api() -> String {
        return ApiUrl.CREATE_ORDERS
    }
    
    func parameters() -> Parameters? {
        return order.createJson()
    }
    
    func paramEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    func isSecret() -> Bool {
        return true
    }
}
