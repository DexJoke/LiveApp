//
//  MessageAlert.swift
//  Greenlaundry
//
//  Created by Nguyễn Tùng Anh on 12/3/20.
//

import Foundation
import UIKit

class MessageAlert {
    private var title: String?
    private var message: String!
    
    init(title: String? = nil,  message: String) {
        self.title = title
        self.message = message
    }
    
    func show(vc: UIViewController, completion: (() -> Void)? = nil) {
            let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { uiAlertAction in
            guard let event = completion else {
                return
            }
            
            event()
        }))
            
        vc.present(alert, animated: true, completion: nil)
    }
    
    
}
