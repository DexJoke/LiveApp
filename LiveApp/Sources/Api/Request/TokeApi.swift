//
//  TokeApi.swift
//  LiveApp
//
//  Created by Tùng Anh Nguyễn on 30/01/2021.
//

import Foundation
import Alamofire
import SwiftyJSON

class TokenApi: BaseAPI, APIDatasource {
    private var userName: String!
    private var roomName: String!
    
    init(userName: String, roomName: String) {
        self.userName = userName
        self.roomName = roomName
    }
    
    func method() -> HTTPMethod {
        return .get
    }
    
    func api() -> String {
        return "\(ApiUrl.TOKEN_API)?identity=\(userName!)&room_name=\(roomName!)"
    }
    
    func parameters() -> Parameters? {
        return nil
    }
    
    func paramEncoding() -> ParameterEncoding {
        return URLEncoding.default
    }
    
    func isSecret() -> Bool {
        return false
    }
}
