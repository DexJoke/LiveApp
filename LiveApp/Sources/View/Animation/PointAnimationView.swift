//
//  PointAnimationView.swift
//  livestream
//
//  Created by anhnt2 on 4/10/20.
//  Copyright © 2020 nguyen tung anh. All rights reserved.
//

import UIKit

class PointAnimationView: UIView {

    enum PathType {
        case one
        case two
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    func animate(icon: UIImage) {
        let imageView = UIImageView(image: icon)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            imageView.isHidden = true
            imageView.removeFromSuperview()
        })
        
        let randomPath = drand48() > 0.5 ? customPath(type: .one) : customPath(type: .two)
        
        let randomDuration: TimeInterval = 3
        
        let positionAnim = positionAnimation(randomDuration, path: randomPath)
        let scaleAnim = scaleAnimation(randomDuration)
        let opacityAnim = opacityAnimation(randomDuration)
        
        let groupAnim = groupAnimation(randomDuration, animations: [positionAnim, scaleAnim, opacityAnim])
        
        imageView.layer.add(groupAnim, forKey: nil)
        CATransaction.commit()
        
        self.addSubview(imageView)
    }
    
    func positionAnimation(_ duration: TimeInterval, path: UIBezierPath) -> CAKeyframeAnimation {
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        positionAnimation.duration = duration
        positionAnimation.path = path.cgPath
        positionAnimation.fillMode = .forwards
        positionAnimation.isRemovedOnCompletion = false
        positionAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        return positionAnimation
    }
    
    func scaleAnimation(_ duration: TimeInterval) -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = duration
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = 1.67
        scaleAnimation.fillMode = .forwards
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        return scaleAnimation
    }
    
    func opacityAnimation(_ duration: TimeInterval) -> CABasicAnimation {
        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.duration = duration
        opacity.fromValue = 1
        opacity.toValue = 0
        opacity.fillMode = .forwards
        opacity.isRemovedOnCompletion = false
        return opacity
    }
    
    func groupAnimation(_ duration: TimeInterval, animations: [CAAnimation]) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.duration = duration
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards
        group.animations = animations
        return group
    }
    
    func customPath(type: PathType) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.bounds.maxX / 2, y: self.bounds.maxY))
        let h = self.bounds.height
        
        let xPosCp1 = type == .one ? self.bounds.maxX : 0
        let xPosCp2 = type == .one ? 0 : self.bounds.maxX
        
        let cp1 = CGPoint(x: self.bounds.maxX / 2, y: 3 * h / 7)
        let cp2 = CGPoint(x: xPosCp1, y: 5 * h / 7)
        let cp3 = CGPoint(x: xPosCp2, y: 5 * h / 7)
        
        let cp4 = CGPoint(x: self.bounds.maxX / 2, y: -h / 7)
        let cp5 = CGPoint(x: xPosCp1, y: h / 7)
        let cp6 = CGPoint(x: xPosCp2, y: h / 7)
        
        path.addCurve(to: cp1, controlPoint1: cp2, controlPoint2: cp3)
        path.addCurve(to: cp4, controlPoint1: cp5, controlPoint2: cp6)
        
        return path
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
