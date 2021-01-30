//
//  LikeAnimationView.swift
//  livestream
//
//  Created by anhnt2 on 4/10/20.
//  Copyright © 2020 nguyen tung anh. All rights reserved.
//

import UIKit

class LikeAnimationView: UIView {
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
        
        let randomDuration: TimeInterval = 3
        let path = generatePath()
        
        let positionAnim = positionAnimation(randomDuration, path: path)
        let opacityAnim = opacityAnimation(randomDuration)
        
        let groupAnim = groupAnimation(randomDuration, animations: [positionAnim, opacityAnim])
        
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
    
    func opacityAnimation(_ duration: TimeInterval) -> CABasicAnimation {
        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.duration = duration
        opacity.fromValue = 1
        opacity.toValue = 0
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
    
    func generatePath() -> UIBezierPath {
        var path: UIBezierPath!
        path = UIBezierPath()
        path.move(to: CGPoint(x: self.bounds.maxX / 2 , y: self.bounds.maxY))
        
        path.addLine(to: CGPoint(x: self.bounds.maxX / 2, y: 0))
        
        return path
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
