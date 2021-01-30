//
//  ConnectionPresenter.swift
//  LiveApp
//
//  Created by Tùng Anh Nguyễn on 30/01/2021.
//

import UIKit

protocol ConnectionDelegate {
    func onStartRequsetToken()
    func onRequestTokenSuccess(token: TokenModel)
    func onRequestTokenFailed(message: String?)
}

class ConnectionPresenter: BasePresenter {
    private var delegate: ConnectionDelegate!
    
    init(delegate: ConnectionDelegate) {
        self.delegate = delegate
    }
    
    
    func requestGetToken(name: String, roomName: String) {
        delegate.onStartRequsetToken()
        let api = TokenApi(userName: name, roomName: roomName)
        request(api: api) { [weak self] json in
            guard let self = self else {
                return
            }
            let token = json["token"].stringValue
            let tokenModel = TokenModel(userName: name, token: token, roomName: roomName)
            self.delegate.onRequestTokenSuccess(token: tokenModel)
        } onError: { [weak self] errorMessage in
            guard let self = self else {
                return
            }
            self.delegate.onRequestTokenFailed(message: errorMessage)
        }
    }
}
