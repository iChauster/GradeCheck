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
        self.tabBar.tintColor = UIColor(red: 55/255, green: 127/255, blue: 58/255, alpha: 1.0);
        let items = self.tabBar.items
        for item in items! {
            let unselectedItem: NSDictionary = [NSForegroundColorAttributeName: UIColor(red: 55/255, green: 127/255, blue: 58/255, alpha: 1.0)]
            let selectedItem: NSDictionary = [NSForegroundColorAttributeName: UIColor(red: 91/255, green: 208/255, blue: 98/255, alpha: 1.0)]
            item.setTitleTextAttributes(unselectedItem as? [String : AnyObject], forState: .Normal)
            item.setTitleTextAttributes(selectedItem as? [String : AnyObject], forState: .Selected)
        }
        
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
        stats.cookie = cookieArray![0] as? String;
        let leftSwipe = UISwipeGestureRecognizer.init(target: self, action: #selector(GradeViewController.swipeLeft))
        leftSwipe.direction = .Left
        self.tabBar.addGestureRecognizer(leftSwipe);
        let rightSwipe = UISwipeGestureRecognizer.init(target: self, action: #selector(GradeViewController.swipeRight))
        rightSwipe.direction = .Right
        self.tabBar.addGestureRecognizer(rightSwipe)
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func swipeLeft(){
        print("swipe left")
        let a = self.selectedIndex
        if (a < 2){
            self.selectedIndex += 1
        }else{
            self.selectedIndex = 0;
        }
    }
    func swipeRight(){
        print("swipe right")
        let a = self.selectedIndex
        if (a > 0){
            self.selectedIndex -= 1
        }else{
            self.selectedIndex = 2;
        }
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
