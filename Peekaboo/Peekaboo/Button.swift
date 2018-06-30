//
//  Button.swift
//  Peekaboo
//
//  Created by Daniel Chen on 6/26/18.
//  Copyright © 2018 Charles Thomas. All rights reserved.
//

import UIKit
var highlitedColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)

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
        
        titleLabel?.adjustsFontForContentSizeCategory = true
        layer.backgroundColor = UIColor.white.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 20
    }

}
