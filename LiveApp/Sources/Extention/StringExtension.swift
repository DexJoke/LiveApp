//
//  StringExtension.swift
//  Greenlaundry
//
//  Created by Nguyễn Tùng Anh on 12/3/20.
//

import Foundation

extension String {
    static func hasValue(string: String?) -> Bool {
        return string != nil && !string!.isEmpty
    }
    
    func isEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    var length: Int {
        return self.count
    }
    
    func VND() -> String {
        return "\(self) VND"
    }
    
    func floatStyle() -> String {
        return self.replacingOccurrences(of: ",", with: ".")
    }
    
    func toDate() -> Date? {
        let dateFor: DateFormatter = DateFormatter()
        dateFor.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let yourDate = dateFor.date(from: self)
        return yourDate
    }
}
