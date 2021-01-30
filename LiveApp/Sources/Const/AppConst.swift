//
//  AppConst.swift
//  Greenlaundry
//
//  Created by Nguyễn Tùng Anh on 12/3/20.
//

import Foundation

class AppConst {
    #if DEBUG
    static let DOMAIN_DEFAULT = "http://api.greenlaundry.vn"
    #elseif STAGING
    static let DOMAIN_DEFAULT = "http://api.greenlaundry.vn"
    #else
    static let DOMAIN_DEFAULT = "http://api.greenlaundry.vn"
    #endif
    
    static let USER_INFOR_KEY = "UserInfor"
    static let APP_NAME = "Greenlaudry"
    static let URL_PRODUCT_IMAGE = "\(DOMAIN_DEFAULT)/public/images/products"
    static let URL_ARTICLES_IMAGE = "\(DOMAIN_DEFAULT)/public/images/articles"
}
