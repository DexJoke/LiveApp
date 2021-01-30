
//
//  BaseViewController.swift
//  Married
//
//  Created by dexjoke on 7/21/20.
//  Copyright © 2020 Anhnt2. All rights reserved.
//

import UIKit
import JGProgressHUD

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    private(set) var hasViewDidAppear = false
    private(set) var hasViewWillAppear = false
    private(set) var hasPop = false
    private var baseNavi: BaseNavigationController? { return self.navigationController as? BaseNavigationController }
    var isEnableBack: Bool { return true }
    var existsNaviBar: Bool { return true }
    var existsTabBar: Bool { return false }
    var existsNaviUnderLine: Bool { return true }
    var hasNavi: Bool { return self.navigationController != nil }
    let hud = JGProgressHUD(style: .dark)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.commonInit()
    }
    
    deinit { print("deinit \(String(describing: type(of: self)))") }
    
    func commonInit() {
        self.navigationItem.hidesBackButton = true
        
        self.hidesBottomBarWhenPushed = !self.existsTabBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !self.hasViewWillAppear {
            self.createBackButton()
        }
        self.baseNavi?.changeNavi(isShow: self.existsNaviUnderLine)
        self.navigationController?.setNavigationBarHidden(!self.existsNaviBar, animated: animated)
        self.hasViewWillAppear = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.enableSwipeBack()
        self.hasViewDidAppear = true
    }
    
    func enableSwipeBack() {
        guard let navigationController = self.navigationController else { return }
        let isEnabled = self.isEnableBack && navigationController.viewControllers.first !== self
        navigationController.interactivePopGestureRecognizer?.isEnabled = isEnabled
        navigationController.interactivePopGestureRecognizer?.delegate = isEnabled ? self : nil
        navigationController.interactivePopGestureRecognizer?.addTarget(self, action: #selector(swipeBack))
    }
    
    func createBackButton() {
        if (self.navigationController?.viewControllers.count ?? 0) <= 1 || self.navigationController?.topViewController !== self { return }
        if !self.isEnableBack { return }
        
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "ic_back")!.withRenderingMode(.alwaysOriginal) , style: .plain, target: self, action: #selector(pushedBackButton))
        self.navigationItem.addLeftBarButtonItem(item: barButtonItem, isLastPosition: false)
    }
    
    @objc func pushedBackButton() {
        if self.hasPop { return }
        if self.backEvent() {
            self.popViewController()
        }
    }
    
    func backEvent() -> Bool { return true }
    
    @objc func swipeBack() {   }
    
    func presentOverContext(vc: UIViewController, animated: Bool = false, completion: (() -> Void)? = nil) {
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalPresentationCapturesStatusBarAppearance = true
        self.present(vc, animated: animated, completion: completion)
    }
    
    func pushViewController(_ viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
        
    func showLoading() {
        hud.vibrancyEnabled = true
        hud.textLabel.text = "Loading"
        hud.shadow = JGProgressHUDShadow(color: .black, offset: .zero, radius: 5.0, opacity: 0.2)
        hud.show(in: (AppDelegate.instance.window?.rootViewController!.view)!)
    }
    
    func hideLoading() {
        hud.dismiss()
    }
    
    func errorWithDescription(description: String, code: Int) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : description]
        return NSError(domain: "app", code: code, userInfo: userInfo)
    }
    
    func hiddenKeyBoard() {
        view.endEditing(false)
    }
}
