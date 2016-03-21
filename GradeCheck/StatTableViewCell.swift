//
//  StatTableViewCell.swift
//  GradeCheck
//
//  Created by Ivan Chau on 3/21/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class StatTableViewCell: UITableViewCell {
    @IBOutlet weak var classTitle : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
