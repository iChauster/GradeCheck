//
//  SettingsViewController.swift
//  GradeCheck
//
//  Created by Ivan Chau on 5/26/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var MHSButton : UIButton!
    @IBOutlet weak var SettingsTable : UITableView!
    let cellTitles = ["Update Password", "Change Student", ""]
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 3;
        }else{
            return 1;
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return "ACCOUNT"
        }else{
            return "STATISTICS"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell") as! SettingsTableViewCell
            cell.title.text = self.cellTitles[indexPath.row];
            return cell;
        }else{
            let switchCell = tableView.dequeueReusableCellWithIdentifier("SettingsSwitchCell") as! SettingsSwitchTableViewCell
            switchCell.segmentControl.setTitle("Weighted GPA", forSegmentAtIndex: 0)
            switchCell.segmentControl.setTitle("Unweighted GPA", forSegmentAtIndex: 1)
            if (NSUserDefaults.standardUserDefaults().objectForKey("GPA") as! String == "Unweighted"){
                switchCell.segmentControl.selectedSegmentIndex = 1;
            }
            switchCell.segmentControl.tintColor = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0)
            return switchCell
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MHSButton.layer.cornerRadius = 10;
        self.MHSButton.clipsToBounds = true;
        self.SettingsTable.layer.cornerRadius = 10;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segueBack(sender:AnyObject){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
