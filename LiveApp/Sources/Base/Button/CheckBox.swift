//
//  CheckBox.swift
//  Greenlaundry
//
//  Created by Tùng Anh Nguyễn on 10/12/2020.
//

import UIKit

class CheckBox: UIButton {
    let checkedImage = UIImage(named: "ic_checked")
    let unCheckImage = UIImage(named: "ic_uncheck")
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(unCheckImage, for: UIControl.State.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.isChecked = false
        self.tintColor = Color.darkBrown
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self && isAutoCheck {
            isChecked = !isChecked
        }
    }
    
    @IBInspectable var isAutoCheck: Bool = false
}
