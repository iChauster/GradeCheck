//
//  PushTableViewCell.swift
//  GradeCheck
//
//  Created by Ivan Chau on 2/7/18.
//  Copyright © 2018 Ivan Chau. All rights reserved.
//

import UIKit

class PushTableViewCell: UITableViewCell {
    @IBOutlet weak var pushToggle : UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func updateUserToken(_ sender:UISwitch){
        if(sender.isOn){
            OneSignal.defaultClient().enable(inAppAlertNotification: true)
            OneSignal.defaultClient().idsAvailable({ (userId, pushToken) in
                print("UserId:%@", userId)
                if (pushToken != nil) {
                    print("pushToken:%@", pushToken)
                    //send userToken
                }
            })
        }else{
            OneSignal.defaultClient().enable(inAppAlertNotification: false)
        }
    }
}
