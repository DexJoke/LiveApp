//
//  TextChatCell.swift
//  livestream
//
//  Created by DaoVanSon on 3/25/20.
//  Copyright © 2020 nguyen tung anh. All rights reserved.
//

import UIKit
import SDWebImage

class TextChatCell: UITableViewCell {
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var containView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(userName: String ,text: String) {
        let attributesName = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor : Color.watermelon]
        let attributesContent = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.white]

        let name = NSMutableAttributedString(string: userName, attributes: attributesName)
        let message = NSMutableAttributedString(string:"  \(text)", attributes: attributesContent)

        name.append(message)
        
        self.lblContent.attributedText = name
    }
    
}
