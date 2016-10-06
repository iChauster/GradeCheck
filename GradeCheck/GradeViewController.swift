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
    let url = "http://gradecheck.herokuapp.com/"
    let keychain = Keychain()
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
        let idObject = (grades[0]["objectID"] as! NSArray)[0] as! String
        let table = self.viewControllers?.first as! GradeTableViewController
        table.gradeArray = grades;
        let assignments = self.viewControllers?[1] as! AssignmentsTableViewController
        let cookieID = grades[0] as! NSDictionary;
        let cookieArray = cookieID.objectForKey("cookie") as? NSArray;
        assignments.cookie = cookieArray![0] as? String;
        assignments.id = cookieID.objectForKey("id") as? String;
        print(cookieID.objectForKey("id") as? String);
        let stats = self.viewControllers?[2] as! StatViewController
        stats.idString = idObject
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
    func refreshAndLogin(cookie:String){
        print(cookie);
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let usernameString = "username=" + (keychain.getPasscode("GCUsername")! as String)
        print(usernameString)
        let passwordString = "&password=" + (keychain.getPasscode("GCPassword")! as String)
        print(passwordString)
        let cookieString = "&cookie=" + cookie;
        print(cookieString);
        let postData = NSMutableData(data: usernameString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(passwordString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(cookieString.dataUsingEncoding(NSUTF8StringEncoding)!)
        if((self.keychain.getPasscode("GCEmail")) != ""){
            let emailString = "&email=" + (self.keychain.getPasscode("GCEmail") as! String)
            postData.appendData(emailString.dataUsingEncoding(NSUTF8StringEncoding)!)
            print("in")
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: url + "relogin")!,
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
                        do{
                            let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray;
                            let dict = jsonDict[0] as! NSDictionary
                            let hafl = dict.objectForKey("cookie") as! NSArray;
                            let table = self.viewControllers?.first as! GradeTableViewController
                            table.cookie = hafl[0] as! String;
                            let assignments = self.viewControllers?[1] as! AssignmentsTableViewController
                            assignments.cookie = hafl[0] as! String;
                            let stats = self.viewControllers?[2] as! StatViewController
                            stats.cookie = hafl[0] as! String;
                        }catch{
                            
                        }
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        let alert = UIAlertController(title: "Connection Error:", message: "Incorrect login or server idle. Please try again. Status Code :" +
                            String(httpResponse!.statusCode), preferredStyle: .Alert);
                        let action = UIAlertAction(title: "OK", style: .Default, handler: { (alert) in
                        })
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil);
                    });
                }
            }
        })
        
        dataTask.resume()
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
