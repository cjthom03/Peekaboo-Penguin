//
//  Button.swift
//  Peekaboo
//
//  Created by Daniel Chen on 6/26/18.
//  Copyright © 2018 Charles Thomas. All rights reserved.
//

import UIKit

class Button: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 22
    }

}
