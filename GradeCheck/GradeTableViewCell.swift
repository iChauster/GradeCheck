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
    @IBOutlet weak var view : UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        switch Int(self.grade.text!)!{
        case 0..<50:
            self.view.backgroundColor = UIColor.blackColor()
        case 51..<75 :
            self.view.backgroundColor = UIColor.redColor()
        case 76..<85 :
            self.view.backgroundColor = UIColor.yellowColor()
        case 86..<110 :
            self.view.backgroundColor = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0);
        default :
            self.view.backgroundColor = UIColor.purpleColor()
        }
        self.view.layer.cornerRadius = 10;
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
