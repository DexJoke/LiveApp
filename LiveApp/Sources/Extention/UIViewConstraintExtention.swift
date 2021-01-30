//
//  UIViewConstraintExtention.swift
//  livestream
//
//  Created by DaoVanSon on 3/20/20.
//  Copyright © 2020 nguyen tung anh. All rights reserved.
//

import UIKit

extension UIView {
    func addXibView(view: UIView) {
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtil.top(item: view, toItem: self, constant: 0)
        ConstraintUtil.leading(item: view, toItem: self, constant: 0)
        ConstraintUtil.trailing(item: view, toItem: self, constant: 0)
        ConstraintUtil.bottom(item: view, toItem: self, constant: 0)
    }
    
    func addSubviewCenter(view: UIView) {
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtil.center(item: view, toItem: self)
    }
    
    func addXibView(view: UIView, leftTop: CGPoint) {
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtil.leftTop(item: view, toItem: self, point: leftTop)
    }
    
    /// https://qiita.com/to4iki/items/51c1b629c2d1884bbeb3
    func addSubViewAndFitParentView(subview: UIView, isSearchBar: Bool = false) {
        subview.frame = self.bounds
        self.addSubview(subview)
        self.addConstraintsFitParentView(selectedView: subview, isSearchBar: isSearchBar)
    }

    private func addConstraintsFitParentView(selectedView: UIView, isSearchBar: Bool) {
        //let topConstant: CGFloat = isSearchBar ? 56.0 : 0.0
        let rightConstant: CGFloat = isSearchBar ? 40.0 : 0.0
        let leftConstant: CGFloat = isSearchBar ? -40.0 : 0.0
        selectedView.translatesAutoresizingMaskIntoConstraints = false

        self.addConstraints([
            NSLayoutConstraint(
                item: selectedView,
                attribute: .left,
                relatedBy: .equal,
                toItem: self,
                attribute: .left,
                multiplier: 1.0,
                constant: leftConstant
            ),
            NSLayoutConstraint(
                item: selectedView,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1.0,
                constant: 0//topConstant
            ),
            NSLayoutConstraint(
                item: selectedView,
                attribute: .right,
                relatedBy: .equal,
                toItem: self,
                attribute: .right,
                multiplier: 1.0,
                constant: rightConstant
            ),
            NSLayoutConstraint(
                item: selectedView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0
            )]
        )
    }
}
