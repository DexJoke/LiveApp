//
//  IntExtention.swift
//  Greenlaundry
//
//  Created by Tùng Anh Nguyễn on 09/12/2020.
//

import Foundation
 
extension Int {
    func rounding() -> Int {
        let value = Int(self / 1000)
        return value * 1000
    }
    
    func df2so() -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = "."
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.decimalSeparator = ","
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: self as NSNumber)!
    }
}
