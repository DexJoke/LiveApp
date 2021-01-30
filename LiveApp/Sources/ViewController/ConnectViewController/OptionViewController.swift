//
//  ConnectViewController.swift
//  LiveApp
//
//  Created by Tùng Anh Nguyễn on 30/01/2021.
//

import UIKit

class OptionViewController: BaseViewController {
    let IDENTIFIER_PUSH_TO_LIVE = "pushToLive"
    let IDENTIFIER_PUSH_TO_VIDEO_CALL = "pushToVideoCall"
    
    static func createForRootViewController() -> BaseNavigationController {
        return ViewUtil.loadStoryboardInitialVC(storyboard: "ConnectViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradienBackground()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == IDENTIFIER_PUSH_TO_LIVE {
            pushToConnectViewController(type: .live, segue: segue)
        } else if segue.identifier == IDENTIFIER_PUSH_TO_VIDEO_CALL {
            pushToConnectViewController(type: .videoCall, segue: segue)
        }
    }
    
    private func pushToConnectViewController(type: ConnectionType, segue: UIStoryboardSegue) {
        if let vc = segue.destination as? ConnectionViewController {
            vc.connectionType = type
        }
    }
    
    func addGradienBackground() {
        let topColor = Color.brown.cgColor
        let bottomColor = Color.lightBrown.cgColor
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.frame = view.bounds

        view.layer.insertSublayer(gradientLayer, at: 0)
    }

}
