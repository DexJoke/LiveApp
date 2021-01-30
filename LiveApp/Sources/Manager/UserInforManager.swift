//
//  UserInforManager.swift
//  Greenlaundry
//
//  Created by Nguyễn Tùng Anh on 12/4/20.
//

import Foundation

enum UserInforKey : String {
   case email = "email key"
}

class UserInforManager {
    
    func getValue<T>(_ key: UserInforKey) -> T {
        return UserDefault.getValue(key: key.rawValue) as! T
    }
    
    func saveValue(_ key: UserInforKey, value: Any) {
        UserDefault.setValue(value: value, key: key.rawValue)
    }
}
