//
//  MarkingPeriodSwitchTableViewCell.swift
//  GradeCheck
//
//  Created by Ivan Chau on 11/14/17.
//  Copyright © 2017 Ivan Chau. All rights reserved.
//

import UIKit

class MarkingPeriodSwitchTableViewCell: UITableViewCell {
    @IBOutlet weak var segControl : UISegmentedControl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func updateMPPreference(_ sender:UISegmentedControl){
        if(sender.selectedSegmentIndex == 0){
            UserDefaults.standard.set("MP1", forKey: "GradeTableMP")
            print("Set to MP1")
        }else if(sender.selectedSegmentIndex == 1){
            UserDefaults.standard.set("MP2", forKey: "GradeTableMP")
            print("Set to MP2")
        }else if(sender.selectedSegmentIndex == 2){
            UserDefaults.standard.set("MP3", forKey: "GradeTableMP")
            print("Set to MP3")
        }else if(sender.selectedSegmentIndex == 3){
            UserDefaults.standard.set("MP4", forKey: "GradeTableMP")
            print("Set to MP4")
        }
        UserDefaults.standard.synchronize()

    }

}
