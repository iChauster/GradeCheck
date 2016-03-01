//
//  GradeTableViewCell.swift
//  GradeCheck
//
//  Created by Ivan Chau on 2/21/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class GradeTableViewCell: UITableViewCell {
    @IBOutlet weak var classg : UILabel!
    @IBOutlet weak var grade : UILabel!
    @IBOutlet weak var teacher : UILabel!
    @IBOutlet weak var views : UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.views.layer.cornerRadius = 10;
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if(selected == true){
            self.views.backgroundColor = UIColor.blackColor()
        }
        // Configure the view for the selected state
    }

}
