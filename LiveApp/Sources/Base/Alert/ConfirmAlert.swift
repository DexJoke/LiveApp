//
//  ConfirmAlert.swift
//  Greenlaundry
//
//  Created by Tùng Anh Nguyễn on 11/12/2020.
//

import Foundation
import UIKit

class ConfirmAlert {
    private var title: String?
    private var message: String!
    
    init(title: String? = nil,  message: String) {
        self.title = title
        self.message = message
    }
    
    func show(vc: UIViewController, completion: ((_ isOk: Bool) -> Void)? = nil) {
            let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Hủy", style: UIAlertAction.Style.default, handler: { uiAlertAction in
            guard let event = completion else {
                return
            }
            event(false)
        }))
        
        alert.addAction(UIAlertAction(title: "Đồng ý", style: UIAlertAction.Style.default, handler: { uiAlertAction in
            guard let event = completion else {
                return
            }
            event(true)
        }))
        
        vc.present(alert, animated: true, completion: nil)
    }
}
