//
//  GradeViewController.swift
//  GradeCheck
//
//  Created by Ivan Chau on 2/21/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class GradeViewController: UITabBarController {
    
    var grades : NSArray!
    var selectedInd : Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Load");
        let table = self.viewControllers?.first as! GradeTableViewController
        table.gradeArray = grades;
        let assignments = self.viewControllers?[1] as! AssignmentsTableViewController
        let cookieID = grades[0] as! NSDictionary;
        let cookieArray = cookieID.objectForKey("cookie") as? NSArray;
        assignments.cookie = cookieArray![0] as? String;
        assignments.id = cookieID.objectForKey("id") as? String;
        print(cookieID.objectForKey("id") as? String);
        let stats = self.viewControllers?[2] as! StatViewController
        stats.gradesArray = grades;


        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
