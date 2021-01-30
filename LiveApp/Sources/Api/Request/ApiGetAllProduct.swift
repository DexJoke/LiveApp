//
//  ApiGetAllProduct.swift
//  Greenlaundry
//
//  Created by Tùng Anh Nguyễn on 08/12/2020.
//

import Foundation
import Alamofire
import SwiftyJSON

class ApiGetAllProduct: BaseAPI, APIDatasource {
    private var orderType: OrderType!
    
    init(orderType: OrderType) {
        self.orderType = orderType
    }
    
    func isSecret() -> Bool {
        return true
    }
    
    func method() -> HTTPMethod {
        .get
    }
    
    func api() -> String {
        return "\(AppConst.DOMAIN_DEFAULT)/api/products?type=\(orderType.rawValue)"
    }
    
    func parameters() -> Parameters? {
        return nil
    }
    
    func paramEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
}
