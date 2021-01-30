//
//  BasePresenter.swift
//  Married
//
//  Created by dexjoke on 7/23/20.
//  Copyright © 2020 Anhnt2. All rights reserved.
//

import Foundation

class BasePresenter: NSObject {
    public func request(api: BaseAPI, onSuccess: @escaping onRequestSuccess, onError: @escaping onRequestError) {
        api.request({ (json) in
            onSuccess(json)
        }) { message in
            onError(message)
        }
    }
}
