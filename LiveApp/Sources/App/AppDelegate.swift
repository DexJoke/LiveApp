//
//  AppDelegate.swift
//  LiveApp
//
//  Created by Tùng Anh Nguyễn on 26/01/2021.
//

import UIKit
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var instance : AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var window: UIWindow? //UIApplic
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = SplashViewController.createFromStoryBoard()
        self.window!.makeKeyAndVisible()
        IQKeyboardManager.shared.enable = true
        
        return true
    }
}

