//
//  UINavigationItemExtention.swift
//  livestream
//
//  Created by DaoVanSon on 3/20/20.
//  Copyright © 2020 nguyen tung anh. All rights reserved.
//

import UIKit

extension UINavigationItem {
    private func barButtonItems(isLeft: Bool) -> [UIBarButtonItem]? {
        return isLeft ? self.leftBarButtonItems : self.rightBarButtonItems
    }
    
    private func setBarButtonItems(isLeft: Bool, barButtonItems: [UIBarButtonItem]?) {
        if isLeft {
            self.leftBarButtonItems = barButtonItems
        } else {
            self.rightBarButtonItems = barButtonItems
        }
    }
    
    private func addBarButtonItem(isLeft: Bool, item: UIBarButtonItem, isLastPostion: Bool) {
        if self.barButtonItems(isLeft: isLeft) == nil {
            self.setBarButtonItems(isLeft: isLeft, barButtonItems: [UIBarButtonItem]())
        }
        var barButtonItems = self.barButtonItems(isLeft: isLeft)!
        if isLastPostion {
            barButtonItems.append(item)
        } else {
            barButtonItems.insert(item, at: 0)
        }
        self.setBarButtonItems(isLeft: isLeft, barButtonItems: barButtonItems)
    }
    
    private func addBarButtonItem(isLeft: Bool, view: UIView, isLastPostion: Bool) {
        let item = UIBarButtonItem(customView: view)
        self.addBarButtonItem(isLeft: isLeft, item: item, isLastPostion: isLastPostion)
    }

    func addLeftBarButtonItem(item: UIBarButtonItem, isLastPosition: Bool = true) {
        self.addBarButtonItem(isLeft: true, item: item, isLastPostion: isLastPosition)
    }
    
    func addLeftBarButtonItem(view: UIView, isLastPosition: Bool = true) {
        self.addBarButtonItem(isLeft: true, view: view, isLastPostion: isLastPosition)
    }
    
    func addRightBarButtonItem(item: UIBarButtonItem, isLastPosition: Bool = true) {
        self.addBarButtonItem(isLeft: false, item: item, isLastPostion: isLastPosition)
    }

    func addRightBarButtonItem(view: UIView, isLastPosition: Bool = true) {
        self.addBarButtonItem(isLeft: false, view: view, isLastPostion: isLastPosition)
    }
}

