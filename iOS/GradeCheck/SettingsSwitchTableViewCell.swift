//
//  SettingsSwitchTableViewCell.swift
//  GradeCheck
//
//  Created by Ivan Chau on 5/30/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class SettingsSwitchTableViewCell: UITableViewCell {
    @IBOutlet weak var segmentControl : UISegmentedControl!
    weak var delegate : ReloadProtocol?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func updateGPAPreference(_ sender:UISegmentedControl){
        if(sender.selectedSegmentIndex == 0){
            UserDefaults.standard.set("Weighted",forKey: "GPA")
            print("Set to Weighted")
        }else if(sender.selectedSegmentIndex == 1){
            UserDefaults.standard.set("Unweighted", forKey: "GPA")
            print("Set to Unweighted")
        }
        delegate?.reloadGPA()
    }

}
