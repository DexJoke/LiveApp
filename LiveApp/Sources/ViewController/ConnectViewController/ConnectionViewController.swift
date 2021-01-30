//
//  ConnectionViewController.swift
//  LiveApp
//
//  Created by Tùng Anh Nguyễn on 30/01/2021.
//

import UIKit

enum ConnectionType {
    case videoCall
    case live
}

class ConnectionViewController: BaseViewController {
    @IBOutlet weak var roomNameViewContainer: UIView!
    @IBOutlet weak var userNameViewContainer: UIView!
    @IBOutlet weak var optionViewContainer: UIView!
    @IBOutlet weak var txtRoomName: UITextField!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var ckHost: CheckBox!
    @IBOutlet weak var ckViewer: CheckBox!

    var connectionType: ConnectionType!
    var presenter: ConnectionPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ConnectionPresenter(delegate: self)
        
        addGradienBackground()
        updateViewForLive()
    }
    
    @IBAction func onPressedHostCheckbox(_ sender: CheckBox) {
        if ckHost.isChecked {
            return
        }
        
        updateViewForOption()
    }
    
    @IBAction func onPressedViewerCheckbox(_ sender: CheckBox) {
        if ckViewer.isChecked {
            return
        }
        updateViewForOption()
    }
    
    @IBAction func onButtonConnectPressed(_ sender: Any) {
        guard let userName = txtUserName.text, let roomName = txtRoomName.text else {
            return
        }
        
        presenter.requestGetToken(name: userName, roomName: roomName)
    }
    
    private func updateViewForOption() {
        ckHost.isChecked = !ckHost.isChecked
        ckViewer.isChecked = !ckViewer.isChecked
    }
    
    private func updateViewForLive() {
        let isLive = connectionType == .live
        ckHost.isChecked = true
        ckViewer.isChecked = false
        
        optionViewContainer.isHidden = !isLive
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

extension ConnectionViewController: ConnectionDelegate {
    func onStartRequsetToken() {
        showLoading()
    }
    
    func onRequestTokenSuccess(token: TokenModel) {
        hideLoading()
        pushViewController(VideoCallVC.create(tokenModel: token))
    }
    
    func onRequestTokenFailed(message: String?) {
        hideLoading()
        MessageAlert(message: message ?? "Không thể kết nối").show(vc: self)
    }
}
