//
//  BaseNavigationController.swift
//  Married
//
//  Created by dexjoke on 7/21/20.
//  Copyright © 2020 Anhnt2. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    private var underLineView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.isTranslucent = false
        navigationBar.barTintColor = Color.darkBrown
        navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white, .font: UIFont.boldSystemFont(ofSize: 15)]
        navigationBar.isTranslucent = false
    }
    
    func changeNavi(isShow: Bool) {
//        if isShow {
//            self.addUnderLine()
//        } else {
//            self.removeUnderLine()
//        }
    }
    
    func addUnderLine() {
        let lineHeight = CGFloat(1)
        self.underLineView?.removeFromSuperview()
        self.underLineView = UIView(frame: CGRect(x: 0, y: self.navigationBar.height - lineHeight, width: self.navigationBar.width, height: lineHeight))
        self.underLineView.backgroundColor = Color.dark
        self.navigationBar.addSubview(self.underLineView)
    }
    
    func removeUnderLine() {
        self.underLineView?.removeFromSuperview()
    }
}
