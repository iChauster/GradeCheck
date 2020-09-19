//
//  GPAViewCell.swift
//  GradeCheck
//
//  Created by Ivan Chau on 10/9/17.
//  Copyright © 2017 Ivan Chau. All rights reserved.
//

import UIKit

class GPAViewCell: UITableViewCell {
    @IBOutlet weak var classg : UILabel!
    @IBOutlet weak var grade : PercentLabel!
    @IBOutlet weak var views : UIView!
    var color : UIColor!
    var percent : Int!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.views.layer.cornerRadius = 10;
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
