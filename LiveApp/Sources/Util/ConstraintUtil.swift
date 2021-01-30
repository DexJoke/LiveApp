//
//  ConstraintUtil.swift
//  livestream
//
//  Created by DaoVanSon on 3/20/20.
//  Copyright © 2020 nguyen tung anh. All rights reserved.
//

import UIKit

class ConstraintUtil {
    static func leading(item: UIView, toItem: UIView, constant: CGFloat) {
        let constraint = NSLayoutConstraint(item: item, attribute: .leading, relatedBy: .equal, toItem: toItem, attribute: .leading, multiplier: 1, constant: constant)
        ConstraintUtil.active(constraint: constraint)
    }
    
    static func trailing(item: UIView, toItem: UIView, constant: CGFloat) {
        let constraint = NSLayoutConstraint(item: item, attribute: .trailing, relatedBy: .equal, toItem: toItem, attribute: .trailing, multiplier: 1, constant: constant)
        ConstraintUtil.active(constraint: constraint)
    }
    
    static func top(item: UIView, toItem: UIView, constant: CGFloat) {
        let constraint = NSLayoutConstraint(item: item, attribute: .top, relatedBy: .equal, toItem: toItem, attribute: .top, multiplier: 1, constant: constant)
        ConstraintUtil.active(constraint: constraint)
    }

    static func bottom(item: UIView, toItem: UIView, constant: CGFloat) {
        let constraint = NSLayoutConstraint(item: item, attribute: .bottom, relatedBy: .equal, toItem: toItem, attribute: .bottom, multiplier: 1, constant: constant)
        ConstraintUtil.active(constraint: constraint)
    }
    
    static func leftTop(item: UIView, toItem: UIView, point: CGPoint) {
        ConstraintUtil.top(item: item, toItem: toItem, constant: point.y)
        ConstraintUtil.leading(item: item, toItem: toItem, constant: point.x)
    }
    
    static func centerX(item: UIView, toItem: UIView) {
        let constraint = NSLayoutConstraint(item: item, attribute: .centerX, relatedBy: .equal, toItem: toItem, attribute: .centerX, multiplier: 1, constant: 0)
        ConstraintUtil.active(constraint: constraint)
    }
    
    static func centerY(item: UIView, toItem: UIView) {
        let constraint = NSLayoutConstraint(item: item, attribute: .centerY, relatedBy: .equal, toItem: toItem, attribute: .centerY, multiplier: 1, constant: 0)
        ConstraintUtil.active(constraint: constraint)
    }
    
    static func center(item: UIView, toItem: UIView) {
        ConstraintUtil.centerX(item: item, toItem: toItem)
        ConstraintUtil.centerY(item: item, toItem: toItem)
    }
    
    static func width(item: UIView, constant: CGFloat) {
        let constraint = NSLayoutConstraint(item: item, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: constant)
        ConstraintUtil.active(constraint: constraint)
    }
    
    static func height(item: UIView, constant: CGFloat, priority: UILayoutPriority = .required) {
        let constraint = NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: constant)
        constraint.priority = priority
        ConstraintUtil.active(constraint: constraint)
    }
    static func heightOut(item: UIView, constant: CGFloat, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: constant)
        constraint.priority = priority
        ConstraintUtil.active(constraint: constraint)
        return constraint
    }
    
    static func changeHeight(item: UIView, constant: CGFloat) {
        if ConstraintUtil.exists(view: item, attribute: .height) {
            ConstraintUtil.changeConstant(view: item, attribute: .height, constant: constant)
        }
    }
    
    static func heightGreater(item: UIView, constant: CGFloat) {
        let constraint = NSLayoutConstraint(item: item, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: constant)
        ConstraintUtil.active(constraint: constraint)
    }
    
    static func size(item: UIView, size: CGSize) {
        self.width(item: item, constant: size.width)
        self.height(item: item, constant: size.height)
    }
    
    static func aspectRatio(item: UIView, ratio: CGFloat) {
        let constraint = NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: item, attribute: .width, multiplier: ratio, constant: 0)
        ConstraintUtil.active(constraint: constraint)
    }
    
    private static func active(constraint: NSLayoutConstraint) {
        NSLayoutConstraint.activate([constraint])
    }
    
    private static func exists(view: UIView, attribute: NSLayoutConstraint.Attribute) -> Bool {
        return view.constraints.filter { $0.firstAttribute == attribute }.count > 0
    }
    
    private static func changeConstant(view: UIView, attribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
        if ConstraintUtil.exists(view: view, attribute: attribute) {
            return view.constraints.filter { $0.firstAttribute == attribute }.first!.constant = constant
        }
    }
}
