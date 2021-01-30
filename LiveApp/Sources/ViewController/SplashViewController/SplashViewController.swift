//
//  SplashViewController.swift
//  Greenlaundry
//
//  Created by Nguyễn Tùng Anh on 12/2/20.
//

import UIKit
import SwiftyJSON
class SplashViewController: BaseViewController {
    static func createFromStoryBoard() -> BaseViewController {
        return ViewUtil.loadStoryboardInitialVC(storyboard: "SplashViewController")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.changeRootView()
        }
    }
    private func changeRootView() {
        ViewUtil.changeRootVC(vc: OptionViewController.createForRootViewController())
    }
}
