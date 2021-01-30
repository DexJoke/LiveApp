//
//  UIViewExtension.swift
//  livestream
//
//  Created by DaoVanSon on 3/23/20.
//  Copyright © 2020 nguyen tung anh. All rights reserved.
//

import UIKit

extension UIView{
    // animation
    func expandAnimation(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.5
            self.alpha = 1
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: completion)
    }
    
    func shrinkAnimation(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: completion)
    }
    
    func removeSubView() {
        for subview in self.subviews {
            subview.removeFromSuperview() }
    }
    
    func cornerRadius(length: CGFloat) {
        self.layer.cornerRadius = length * DeviceUtil.basicRatio
        self.clipsToBounds = true
    }
    
    func changeCircle() {
        self.cornerRadius(length: min(self.width, self.height) / 2)
    }
    
    func scaleAnimation(duration: TimeInterval, delay: TimeInterval = 0, scale: [Double]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            bounceAnimation.values = scale
            bounceAnimation.duration = TimeInterval(duration)
            bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
            self.layer.add(bounceAnimation, forKey: nil)
        }
    }
    
    func removeFromStackView() {
        guard let stackView = self.superview as? UIStackView  else { return }
        stackView.removeArrangedSubview(self)
        self.removeFromSuperview()
    }
    
    func hasSubview(viewType: UIView.Type) -> Bool {
        if type(of: self) == viewType { return true }
        for subview in self.subviews {
            if subview.hasSubview(viewType: viewType) { return true }
        }
        return false
    }
    
    var width : CGFloat {
        get { return self.frame.size.width }
        set { self.frame.size.width = newValue }
    }
    
    var height : CGFloat {
        get { return self.frame.size.height }
        set { self.frame.size.height = newValue }
    }
    
    var aspectRatio : CGFloat { return self.width == 0 ? 0 : self.height / self.width }
    
    var size : CGSize {
        get { return self.frame.size }
        set { self.frame.size = newValue }
    }
    
    var left : CGFloat {
        get { return self.frame.origin.x }
        set { self.frame.origin.x = newValue }
    }
    
    var right : CGFloat {
        get { return self.frame.origin.x + self.width }
        set { self.frame.origin.x = newValue - self.width }
    }
    
    var top : CGFloat {
        get { return self.frame.origin.y }
        set { self.frame.origin.y = newValue }
    }
    
    var bottom : CGFloat {
        get { return self.frame.origin.y + self.height }
        set { self.frame.origin.y = newValue - self.height }
    }
    
    var centerX : CGFloat {
        get { return self.frame.origin.x + self.width / 2 }
        set { self.frame.origin.x = newValue - self.width / 2 }
    }
    
    var centerY : CGFloat {
        get { return self.frame.origin.y + self.height / 2 }
        set { self.frame.origin.y = newValue - self.height / 2 }
    }
    
    var topLeft : CGPoint {
        get { return CGPoint(x: self.left, y: self.top) }
        set { self.left = newValue.x
            self.top = newValue.y }
    }
    
    var topCenter : CGPoint {
        get { return CGPoint(x: self.centerX, y: self.top) }
        set {
            self.centerX = newValue.x
            self.top = newValue.y
        }
    }
    
    var topRight : CGPoint {
        get { return CGPoint(x: self.right, y: self.top) }
        set {
            self.right = newValue.x
            self.top = newValue.y
        }
    }
    
    var centerLeft : CGPoint {
        get { return CGPoint(x: self.left, y: self.centerY) }
        set {
            self.left = newValue.x
            self.centerY = newValue.y
        }
    }
    
    var centerRight : CGPoint {
        get { return CGPoint(x: self.right, y: self.centerY) }
        set {
            self.right = newValue.x
            self.centerY = newValue.y
        }
    }
    
    var bottomLeft : CGPoint {
        get { return CGPoint(x: self.left, y: self.bottom) }
        set {
            self.left = newValue.x
            self.bottom = newValue.y
        }
    }
    
    var bottomCenter : CGPoint {
        get { return CGPoint(x: self.centerX, y: self.bottom) }
        set {
            self.centerX = newValue.x
            self.bottom = newValue.y
        }
    }
    
    var bottomRight : CGPoint {
        get { return CGPoint(x: self.right, y: self.bottom) }
        set {
            self.right = newValue.x
            self.bottom = newValue.y
        }
    }
    
    var halfWidth : CGFloat { return self.width / 2 }
    var halfHeight : CGFloat { return self.height / 2 }
    var halfPoint : CGPoint { return CGPoint(x: self.halfWidth, y: self.halfHeight) }
    var halfSize : CGSize { return CGSize(width: self.halfWidth, height: self.halfHeight) }
    
    
    var baseWidth : CGFloat {
        get { return self.width / DeviceUtil.basicRatio }
        set { self.width = newValue * DeviceUtil.basicRatio }
    }
    
    var baseHeight : CGFloat {
        get { return self.height / DeviceUtil.basicRatio }
        set { self.height = newValue * DeviceUtil.basicRatio }
    }
    
    
    var baseLeft : CGFloat {
        get { return self.left / DeviceUtil.basicRatio }
        set { self.left = newValue * DeviceUtil.basicRatio }
    }
    
    var baseRight : CGFloat {
        get { return self.right / DeviceUtil.basicRatio }
        set { self.right = newValue * DeviceUtil.basicRatio }
    }
    
    var baseTop : CGFloat {
        get { return self.top / DeviceUtil.basicRatio }
        set { self.top = newValue * DeviceUtil.basicRatio }
    }
    
    var baseBottom : CGFloat {
        get { return self.bottom / DeviceUtil.basicRatio }
        set { self.bottom = newValue * DeviceUtil.basicRatio }
    }
    
    var baseCenterX : CGFloat {
        get { return self.centerX / DeviceUtil.basicRatio }
        set { self.centerX = newValue * DeviceUtil.basicRatio }
    }
    
    var baseCenterY : CGFloat {
        get { return self.centerY / DeviceUtil.basicRatio }
        set { self.centerY = newValue * DeviceUtil.basicRatio }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return layer.borderColor.map { UIColor(cgColor: $0) }
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    /// 枠線のWidth
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    /// 角丸の大きさ
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    /// 影の色
    @IBInspectable var shadowColor: UIColor? {
        get {
            return layer.shadowColor.map { UIColor(cgColor: $0) }
        }
        set {
            layer.shadowColor = newValue?.cgColor
            layer.masksToBounds = false
        }
    }
    
    /// 影の透明度
    @IBInspectable var shadowAlpha: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    /// 影のオフセット
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    /// 影のぼかし量
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
}



