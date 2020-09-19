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
            let unselectedItem: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor(red: 55/255, green: 127/255, blue: 58/255, alpha: 1.0)]
            let selectedItem: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor(red: 91/255, green: 208/255, blue: 98/255, alpha: 1.0)]
            item.setTitleTextAttributes(unselectedItem as? [NSAttributedStringKey : AnyObject], for: UIControlState())
            item.setTitleTextAttributes(selectedItem as? [NSAttributedStringKey : AnyObject], for: .selected)
        }
        
        print("Load");
        let g = grades[0] as! NSDictionary
        let idObject = (g["objectID"] as! NSArray)[0] as! String
        let table = self.viewControllers?.first as! GradeTableViewController
        table.gradeArray = grades;
        let assignments = self.viewControllers?[1] as! AssignmentsTableViewController
        let cookieID = grades[0] as! NSDictionary;
        let cookieArray = cookieID.object(forKey: "cookie") as? NSArray;
        assignments.cookie = cookieArray![0] as? String;
        assignments.id = cookieID.object(forKey: "id") as? String;
        print(cookieID.object(forKey: "id") as? String);
        let stats = self.viewControllers?[2] as! StatViewController
        stats.idString = idObject
        stats.gradesArray = grades;
        stats.cookie = cookieArray![0] as? String;
        
        let leftSwipe = UISwipeGestureRecognizer.init(target: self, action: #selector(GradeViewController.swipeLeft))
        leftSwipe.direction = .left
        self.tabBar.addGestureRecognizer(leftSwipe);
        let rightSwipe = UISwipeGestureRecognizer.init(target: self, action: #selector(GradeViewController.swipeRight))
        rightSwipe.direction = .right
        self.tabBar.addGestureRecognizer(rightSwipe)
        // Do any additional setup after loading the view.
    }
    @objc func refreshAndLogin(_ cookie:String, comp: @escaping (_ needsReload : Bool) -> Void) {
        print(cookie);
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let usernameString = "username=" + (keychain.getPasscode(identifier: "GCUsername")! as String)
        print(usernameString)
        let passwordString = "&password=" + (keychain.getPasscode(identifier: "GCPassword")! as String)
        print(passwordString)
        let cookieString = "&cookie=" + cookie;
        print(cookieString);
        var postData = NSData(data: usernameString.data(using: String.Encoding.utf8)!) as Data
        postData.append(passwordString.data(using: String.Encoding.utf8)!)
        postData.append(cookieString.data(using: String.Encoding.utf8)!)
        if((self.keychain.getPasscode(identifier: "GCEmail")) != ""){
            let emailString = "&email=" + (self.keychain.getPasscode(identifier: "GCEmail")!)
            postData.append(emailString.data(using: String.Encoding.utf8)!)
            print("in")
        }
        
        let request = NSMutableURLRequest(url: URL(string: url + "relogin")!,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
                if(httpResponse?.statusCode == 200){
                    DispatchQueue.main.async(execute: {
                        do{
                            let jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray;
                            let dict = jsonDict[0] as! NSDictionary
                            let hafl = dict.object(forKey: "cookie") as! NSArray;
                            let table = self.viewControllers?.first as! GradeTableViewController
                            table.cookie = hafl[0] as! String;
                            let assignments = self.viewControllers?[1] as! AssignmentsTableViewController
                            assignments.cookie = hafl[0] as! String;
                            let stats = self.viewControllers?[2] as! StatViewController
                            stats.cookie = hafl[0] as! String;
                            comp(true)
                        }catch{
                            
                        }
                    })
                }else{
                    DispatchQueue.main.async(execute: {
                        
                        let alert = UIAlertController(title: "Connection Error:", message: "Incorrect login or server idle. Please try again. Status Code :" +
                            String(httpResponse!.statusCode), preferredStyle: .alert);
                        let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                        })
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil);
                    });
                }
            }
        })
        
        dataTask.resume()
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func swipeLeft(){
        print("swipe left")
        let a = self.selectedIndex
        if (a < 2){
            self.selectedIndex += 1
        }else{
            self.selectedIndex = 0;
        }
    }
    @objc func swipeRight(){
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
