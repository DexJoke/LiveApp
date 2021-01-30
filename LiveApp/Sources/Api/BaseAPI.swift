//
//  APIService.swift
//  livestream
//
//  Created by DaoVanSon on 3/10/20.
//  Copyright © 2020 nguyen tung anh. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol APIDatasource {
    func method() -> HTTPMethod
    func api() -> String
    func parameters() -> Parameters?
    func paramEncoding() -> ParameterEncoding
    func isSecret() -> Bool
}

typealias onRequestSuccess = (_ apiResult: JSON) -> Void
typealias onRequestError = (_ errorMessage: String?) -> Void

class BaseAPI {
    
    var apiSource: APIDatasource {
        return self as! APIDatasource
    }
    
    var onSuccess: onRequestSuccess!
    var onError: onRequestError!
    
    private func getBasicHeaders(withAuth: Bool) -> HTTPHeaders {
        var headers = ["Content-Type": "application/json"]
        if withAuth {

        }
        return HTTPHeaders.init(headers)
    }
    
    func request(_ onSuccess: @escaping onRequestSuccess, onError: @escaping onRequestError) {
        if !hasConnection() {
            onError("Kết nối không ổn định")
            return
        }
        
        self.onSuccess = onSuccess
        self.onError = onError
        let url = apiSource.api()
        
        let params = apiSource.parameters()
        let method = apiSource.method()
        let paramEncoding = apiSource.paramEncoding()
        let header = getBasicHeaders(withAuth: apiSource.isSecret())
        print("--------------------------")
        print("url: \(url)")
        print("header: \(header)")
        print("params: \(String(describing: params))")
        print("--------------------------")

        AF.request(url, method: method, parameters: params, encoding: paramEncoding , headers: header).responseJSON { (response) in
            self.handleResponse(response)
        }
    }
    
    private func hasConnection() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false

    }
    
    private func handleResponse(_ response: DataResponse<Any, AFError>) {
        switch response.result {
        case .success:
            handleSuccess(response)
            break
        case .failure (let error):
            handleError(error)
            break
        }
    }
    
    private func handleSuccess(_ response: DataResponse<Any, AFError>) {
        guard let json = try? JSON(data: response.data!) else {
            self.onError("Parse Failed")
            return
        }
        print("response: \(json)")

//        if !json["success"].boolValue {
//            self.onError(json["message"].stringValue)
//            return
//        }
        
        onSuccess(json)
    }
    
    private func handleError(_ error: Error) {
        onError(error.localizedDescription)
    }
}

