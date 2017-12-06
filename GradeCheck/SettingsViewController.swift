//
//  SettingsViewController.swift
//  GradeCheck
//
//  Created by Ivan Chau on 5/26/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var MHSButton : UIButton!
    @IBOutlet weak var SettingsTable : UITableView!
    let cellTitles = ["Log Out"]
    let url = "http://localhost:2800/"
    var objectID = "";

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1;
        }else{
            return 2;
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return "ACCOUNT"
        }else{
            return "GRADES"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as! SettingsTableViewCell
            cell.title.text = self.cellTitles[indexPath.row];
            cell.intention = self.cellTitles[indexPath.row];
            return cell;
        }else{
            if(indexPath.row == 0){
                let switchCell = tableView.dequeueReusableCell(withIdentifier: "SettingsSwitchCell") as! SettingsSwitchTableViewCell
                switchCell.segmentControl.setTitle("Weighted GPA", forSegmentAt: 0)
                switchCell.segmentControl.setTitle("Unweighted GPA", forSegmentAt: 1)
                if (UserDefaults.standard.object(forKey: "GPA") as! String == "Unweighted"){
                    switchCell.segmentControl.selectedSegmentIndex = 1;
                }
                switchCell.segmentControl.tintColor = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0)
                return switchCell
            }else{
                let mpSwitchCell = tableView.dequeueReusableCell(withIdentifier: "MarkingPeriodSwitchCell") as! MarkingPeriodSwitchTableViewCell
                
                if let string = UserDefaults.standard.object(forKey: "GradeTableMP") as? String {
                
                    if(string == "MP1"){
                        mpSwitchCell.segControl.selectedSegmentIndex = 0
                    }else if(string == "MP2"){
                        mpSwitchCell.segControl.selectedSegmentIndex = 1
                    }else if(string == "MP3"){
                        mpSwitchCell.segControl.selectedSegmentIndex = 2
                    }else if(string == "MP4"){
                        mpSwitchCell.segControl.selectedSegmentIndex = 3
                    }
                }
                mpSwitchCell.segControl.tintColor = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0)
                return mpSwitchCell
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(objectID)
        self.MHSButton.layer.cornerRadius = 10;
        self.MHSButton.clipsToBounds = true;
        self.SettingsTable.layer.cornerRadius = 10;
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            let cell = self.SettingsTable.cellForRow(at: indexPath) as! SettingsTableViewCell
            if(cell.intention == "Log Out"){
                let key = Keychain()
                key.setPasscode(identifier: "GCUsername", passcode: "");
                key.setPasscode(identifier: "GCPassword", passcode: "");
                key.setPasscode(identifier: "GCEmail", passcode:  "");
                UserDefaults.standard.set(false, forKey: "HasRegistered")
                UserDefaults.standard.set(nil, forKey: "GradeTableMP")
                UserDefaults.standard.set("", forKey: "id");
                UserDefaults.standard.synchronize()
                self.performSegue(withIdentifier: "Reset", sender: nil)
            }
        }
    }
    func updateUser(_ field : String, value : String){
         /* print(field + " " + value);
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let string = field + "=" + value;
        print(string)
        
        let postData = NSMutableData(data: string.dataUsingEncoding(NSUTF8StringEncoding)!)
            let id = "&id=" + self.objectID
            postData.appendData(id.dataUsingEncoding(NSUTF8StringEncoding)!);
        
        let request = NSMutableURLRequest(URL: NSURL(string: url + "update")!,
                                          cachePolicy: .UseProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.HTTPBody = postData
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? NSHTTPURLResponse
                print(httpResponse)
                if(httpResponse?.statusCode == 200){
                    dispatch_async(dispatch_get_main_queue(), {
                    
                    })
                }else if (httpResponse?.statusCode == 1738){
                    dispatch_async(dispatch_get_main_queue(), {
                        let alert = UIAlertController(title: "Username Taken.", message: "It seems like you've logged on before. Please login with your student id and genesis password to regain access. Thanks!", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "10/10", style: .Default, handler: nil)
                        alert.addAction(action);
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
            }
        })
        
        dataTask.resume() */
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segueBack(_ sender:AnyObject){
        self.dismiss(animated: true, completion: nil)
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
