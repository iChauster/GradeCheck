//
//  DetailStatTableViewCell.swift
//  GradeCheck
//
//  Created by Ivan Chau on 3/30/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class DetailStatTableViewCell: UITableViewCell {
    @IBOutlet weak var dataView : basicCircleView!;
    @IBOutlet weak var titleLabel : UILabel!;
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.dataView.layer.cornerRadius = self.dataView.bounds.size.width * 0.5;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
