//
//  ViewUtil.swift
//  Married
//
//  Created by dexjoke on 7/21/20.
//  Copyright © 2020 Anhnt2. All rights reserved.
//

import Foundation
import UIKit

class ViewUtil {
    static func loadNib<T>(name: String) -> T {
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! T
    }
    //Storyboard名とStoryboardIDからVCをインスタンス化
    static func loadStoryboardVC<Type>(storyboard: String, identifier: String) -> Type {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! Type
    }
    
    //Storyboard名から最初のVCをインスタンス化
    static func loadStoryboardInitialVC<Type>(storyboard: String) -> Type {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        return storyboard.instantiateInitialViewController() as! Type
    }
    
    static func changeRootVC(vc: UIViewController) {
        AppDelegate.instance.window!.rootViewController = vc
    }
}
