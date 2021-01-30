//
//  Color.swift
//  Test
//
//  Created by tanaka on 2016/11/11.
//  Copyright © 2016年 田中 雄次郎. All rights reserved.
//

import UIKit

class Color {
    static var darkBrown : UIColor {
        return UIColor.rgb16(hex: 0x594a2a)
    }
    
    static var brown : UIColor {
        return UIColor.rgb16(hex: 0x877553)
    }
    
    static var dark : UIColor {
        return UIColor.rgb16(hex: 0x29210c)
    }
    
    static var lightBrown : UIColor {
        return UIColor.rgb16(hex: 0xf5d8a4)
    }
    
    static var white: UIColor { return UIColor.rgb16(hex: 0xffffff) }
    static var black: UIColor { return UIColor.rgb16(hex: 0x000000) }
    static var watermelon: UIColor { return UIColor.rgb16(hex: 0xff4768) }
    static var white50: UIColor { return UIColor.rgba(r: 255, g: 255, b: 255, alpha: 0.5) }
}
