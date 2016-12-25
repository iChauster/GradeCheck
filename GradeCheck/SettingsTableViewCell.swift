//
//  SettingsTableViewCell.swift
//  GradeCheck
//
//  Created by Ivan Chau on 5/30/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var title : UILabel!
    var intention = "";
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
