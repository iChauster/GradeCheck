//
//  SlideCell.swift
//  GradeCheck
//
//  Created by Ivan Chau on 9/3/17.
//  Copyright © 2017 Ivan Chau. All rights reserved.
//

import UIKit

class SlideCell: UIView {
    @IBOutlet weak var teacher : UILabel!
    @IBOutlet weak var course : UILabel!
    @IBOutlet weak var grade : UILabel!
    @IBOutlet weak var content : UIView!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.content.layer.cornerRadius = 10
    }
    

}
