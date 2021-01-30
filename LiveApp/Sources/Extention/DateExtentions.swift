//
//  DateExtentions.swift
//  Greenlaundry
//
//  Created by Tùng Anh Nguyễn on 16/12/2020.
//

import Foundation

enum DateFormat: String {
    case DMY = "dd-MM-yyyy"
    case HM = "HH:mm"
}

extension Date {
   
    
    func toString(format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
}
