//
//  UserDefault.swift
//  Greenlaundry
//
//  Created by Nguyễn Tùng Anh on 12/3/20.
//

import Foundation

class UserDefault {
    static func existsKey(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    static func getValue(key: String, defaultValue: Any? = nil) -> Any? {
        return UserDefault.existsKey(key: key) ? UserDefaults.standard.object(forKey: key) : defaultValue
    }
    
    static func setValue(value: Any, key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    static func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    static func getString(key: String, defaultValue: String? = nil) -> String? {
        return UserDefault.existsKey(key: key) ? UserDefaults.standard.string(forKey: key) : defaultValue
    }
    
}
