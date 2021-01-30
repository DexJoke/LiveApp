//
//  UIColorExtension.swift
//  Test
//
//  Created by tanaka on 2016/11/11.
//  Copyright © 2016年 田中 雄次郎. All rights reserved.
//

import UIKit

extension UIColor {
    class func rgba(r: UInt, g: UInt, b: UInt, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    class func rgb(r: UInt, g: UInt, b: UInt) -> UIColor{
        return UIColor.rgba(r:r, g:g, b:b, alpha:1)
    }
    
    class func rgba16(hex: UInt, alpha: CGFloat) -> UIColor {
        return UIColor.rgba(r: (hex & 0xFF0000) >> 16, g: (hex & 0x00FF00) >> 8, b: hex & 0x0000FF, alpha: alpha)
    }
    
    class func rgb16(hex: UInt) -> UIColor {
        return UIColor.rgba16(hex: hex, alpha: 1)
    }
    
    class func colorWithHexString (_ hex:String) -> UIColor {
        
        let cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if ((cString as String).count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(with: NSRange(location: 0, length: 2))
        let gString = (cString as NSString).substring(with: NSRange(location: 2, length: 2))
        let bString = (cString as NSString).substring(with: NSRange(location: 4, length: 2))
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(
            red: CGFloat(Float(r) / 255.0),
            green: CGFloat(Float(g) / 255.0),
            blue: CGFloat(Float(b) / 255.0),
            alpha: CGFloat(Float(1.0))
        )
    }
}
