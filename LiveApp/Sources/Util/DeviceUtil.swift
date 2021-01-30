//
//  DeviceUtil.swift
//  livestream
//
//  Created by DaoVanSon on 3/23/20.
//  Copyright © 2020 nguyen tung anh. All rights reserved.
//

import SystemConfiguration
import UIKit

class DeviceUtil{
    private static let width4inch: CGFloat = 320
    private static let width4_7inch: CGFloat = 375
    private static let width5_5inch: CGFloat = 414
    private static let height3_5inch: CGFloat = 480
    private static let height4inch: CGFloat = 568
    private static let height4_7inch: CGFloat = 667
    private static let height5_8inch: CGFloat = 812
    private static let height6_1inch: CGFloat = 896
    private static let height6_5inch: CGFloat = 896
    private static var deviceTypeValue: String!

    private static var osVersion: Int { return Int(UIDevice.current.systemVersion.components(separatedBy: ".")[0])! }
    
    static var isIOS10: Bool {return DeviceUtil.osVersion == 10 }
    static var isIOS11: Bool {return DeviceUtil.osVersion == 11 }
    static var isIOS12: Bool {return DeviceUtil.osVersion == 12 }
    static var isIOS13: Bool {return DeviceUtil.osVersion == 13 }
    static var isIOS10AndLater: Bool { return DeviceUtil.osVersion >= 10 }
    static var isIOS11AndLater: Bool { return DeviceUtil.osVersion >= 11 }
    static var isIOS12AndLater: Bool { return DeviceUtil.osVersion >= 12 }
    static var isIOS13AndLater: Bool { return DeviceUtil.osVersion >= 13 }
    static var screenWidth: CGFloat { return UIScreen.main.bounds.size.width }
    static var screenHeight: CGFloat { return UIScreen.main.bounds.size.height }
    static var baseWidth: CGFloat { return DeviceUtil.width4_7inch }
    static var baseHeight: CGFloat { return DeviceUtil.height4_7inch }
    static var screenSize: CGSize { return CGSize(width: DeviceUtil.screenWidth, height: DeviceUtil.screenHeight) }
    static var is3_5inch: Bool { return DeviceUtil.screenWidth == DeviceUtil.width4inch && DeviceUtil.screenHeight == DeviceUtil.height3_5inch }
    static var is4inch: Bool{ return DeviceUtil.screenWidth == DeviceUtil.width4inch && DeviceUtil.screenHeight == DeviceUtil.height4inch }
    static var lessThan4inch: Bool { return DeviceUtil.is3_5inch || DeviceUtil.is4inch }
    static var is4_7inch: Bool { return DeviceUtil.screenWidth == DeviceUtil.width4_7inch && DeviceUtil.screenHeight == DeviceUtil.height4_7inch }
    static var is5_5inch: Bool { return DeviceUtil.screenWidth == DeviceUtil.width5_5inch }
    static var is5_8inch: Bool { return DeviceUtil.screenHeight == DeviceUtil.height5_8inch }
    static var is6_1inch: Bool { return DeviceUtil.screenHeight == DeviceUtil.height6_1inch }
    static var is6_5inch: Bool { return DeviceUtil.screenHeight == DeviceUtil.height6_5inch }
    static var hasSafeArea: Bool { return DeviceUtil.is5_8inch }
    
    static var basicRatio: CGFloat{ return DeviceUtil.screenWidth / DeviceUtil.width4_7inch }
    static let statusBarHeight: CGFloat = 20
    static let naviBarHeight: CGFloat = 44
    static let naviHeight: CGFloat = (DeviceUtil.hasSafeArea ? DeviceUtil.safeAreaTop  : DeviceUtil.statusBarHeight) + DeviceUtil.naviBarHeight

    static let tabBarHeight: CGFloat = 49
    static let safeAreaTop: CGFloat = 44
    static let safeAreaBottom: CGFloat = 34
    static let safeAreaEar: CGFloat = 30
    
    static func rect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> CGRect {
        return CGRect(x: x * DeviceUtil.basicRatio, y: y * DeviceUtil.basicRatio, width: width * DeviceUtil.basicRatio, height: height * DeviceUtil.basicRatio)
    }
    
    static var isX: Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height == 2436 {
                return true
            }
        }
        return false
    }

    static var deviceType: String {
        if DeviceUtil.deviceTypeValue == nil {
            var size = 0
            sysctlbyname("hw.machine", nil, &size, nil, 0)
            var machine = [CChar](repeating: 0, count: size)
            sysctlbyname("hw.machine", &machine, &size, nil, 0)
            let code = String(cString: machine)
            DeviceUtil.deviceTypeValue = code
        }
        return DeviceUtil.deviceTypeValue
    }
    static var isPlus: Bool {
        return UIDevice.modelName.contains("Plus")
    }
    static var isPro: Bool {
        return UIDevice.modelName.contains("Pro")
    }
}

///https://medium.com/ios-os-x-development/get-model-info-of-ios-devices-18bc8f32c254
public extension UIDevice {
  static let modelName: String = {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
    
    func mapToDevice(identifier: String) -> String {
      #if os(iOS)
      switch identifier {
      case "iPod5,1":                                 return "iPod Touch 5"
      case "iPod7,1":                                 return "iPod Touch 6"
      case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
      case "iPhone4,1":                               return "iPhone 4s"
      case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
      case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
      case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
      case "iPhone7,2":                               return "iPhone 6"
      case "iPhone7,1":                               return "iPhone 6 Plus"
      case "iPhone8,1":                               return "iPhone 6s"
      case "iPhone8,2":                               return "iPhone 6s Plus"
      case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
      case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
      case "iPhone8,4":                               return "iPhone SE"
      case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
      case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
      case "iPhone10,3", "iPhone10,6":                return "iPhone X"
      case "iPhone11,2":                              return "iPhone XS"
      case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
      case "iPhone11,8":                              return "iPhone XR"
      case "iPhone12,1":                              return "iPhone 11"
      case "iPhone12,3":                              return "iPhone 11 Pro"
      case "iPhone12,5":                              return "iPhone 11 Pro Max"
      case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
      case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
      case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
      case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
      case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
      case "iPad6,11", "iPad6,12":                    return "iPad 5"
      case "iPad7,5", "iPad7,6":                      return "iPad 6"
      case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
      case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
      case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
      case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
      case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
      case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
      case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
      case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
      case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
      case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
      case "AppleTV5,3":                              return "Apple TV"
      case "AppleTV6,2":                              return "Apple TV 4K"
      case "AudioAccessory1,1":                       return "HomePod"
      case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
      default:                                        return identifier
      }
      #endif
    }
    
    return mapToDevice(identifier: identifier)
  }()
}
