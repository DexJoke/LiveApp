//
//  ApiGetNews.swift
//  Greenlaundry
//
//  Created by Tùng Anh Nguyễn on 31/12/2020.
//

import Foundation
import SwiftyJSON
import Alamofire

class ApiGetNews: BaseAPI, APIDatasource {
    private var limit: Int?
    
    init(limit: Int? = nil) {
        self.limit = limit
    }
    
    func method() -> HTTPMethod {
        return .get
    }
    
    func api() -> String {
        return limit == nil ? ApiUrl.GET_NEWS : "\(ApiUrl.GET_NEWS)?limit=\(limit!)"
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
