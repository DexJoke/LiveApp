//
//  ImageViewCell.swift
//  DeeplabOnIOS
//
//  Created by DaoVanSon on 10/8/20.
//

import UIKit

class ImageViewCell: UICollectionViewCell {
    @IBOutlet weak var bgImgV: UIImageView!
    @IBOutlet weak var noneView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        noneView.layer.cornerRadius = 10.0
        bgImgV.layer.cornerRadius = 10.0
        bgImgV.clipsToBounds = true
    }
    
    func bindData(_ imageName: String, _ indexP: IndexPath) {
        if indexP.row == 0 {
            noneView.isHidden = false
            bgImgV.isHidden = true
        } else {
            noneView.isHidden = true
            bgImgV.isHidden = false
            bgImgV.image = UIImage(named: imageName)
        }
    }

}
