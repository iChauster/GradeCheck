//
//  LoginViewController.swift
//  GradeCheck
//
//  Created by Ivan Chau on 2/21/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var usn : UITextField!
    @IBOutlet weak var psw : UITextField!
    @IBOutlet weak var login : UIButton!
    @IBOutlet weak var regist : UIButton!
    let keychain = Keychain()
    var jsonDict : NSArray!
    var confirmationDict : NSArray!
    var loggedIn = false;
    @IBAction func login(sender:UIButton!){
        NSLog("clicked");
        NSLog(usn!.text!);
        NSLog(psw.text!);
        self.usn.resignFirstResponder()
        self.psw.resignFirstResponder()
        if(self.usn.text == "" || self.psw.text == ""){
            let alert = UIAlertController(title: "funni", message: "Are you really?", preferredStyle: .Alert);
            let o = UIAlertAction(title: "srry", style: .Default, handler: nil);
            alert.addAction(o)
            self.presentViewController(alert, animated: true, completion: nil);
            return;
        }else{
            self.makeLoginRequestWithParams(self.usn.text!, pass: self.psw.text!);
        }
    }
    @IBAction func register(sender:UIButton!){
        NSLog("clicked");
        NSLog(usn!.text!);
        NSLog(psw.text!);
        self.usn.resignFirstResponder()
        self.psw.resignFirstResponder()
        if(self.usn.text == "" || self.psw.text == ""){
            let alert = UIAlertController(title: "funni", message: "Are you really?", preferredStyle: .Alert);
            let o = UIAlertAction(title: "srry", style: .Default, handler: nil);
            alert.addAction(o)
            self.presentViewController(alert, animated: true, completion: nil);
            return;
        }else{
            let headers = [
                "cache-control": "no-cache",
                "content-type": "application/x-www-form-urlencoded"
            ]
            let usernameString = "username=" + usn!.text!
            let passwordString = "&password=" + psw.text!
            let postData = NSMutableData(data: usernameString.dataUsingEncoding(NSUTF8StringEncoding)!)
            postData.appendData(passwordString.dataUsingEncoding(NSUTF8StringEncoding)!)
            if(NSUserDefaults.standardUserDefaults().boolForKey("PushNotifs")){
                let deviceTokenString = "&deviceToken=" + (NSUserDefaults.standardUserDefaults().objectForKey("deviceToken") as! String)
                postData.appendData(deviceTokenString.dataUsingEncoding(NSUTF8StringEncoding)!)
            }
            
            
            let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:3000/register")!,
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
                                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasRegistered")
                                NSUserDefaults.standardUserDefaults().synchronize()
                                self.makeLoginRequestWithParams(self.usn!.text!, pass: self.psw.text!)
                        })
                    }
                }
            })
            
            dataTask.resume()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIGraphicsBeginImageContext(self.view.frame.size);
        let image = UIImage(named: "back1.png")
        image?.drawInRect(self.view.bounds)
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image!)
        if(!NSUserDefaults.standardUserDefaults().boolForKey("HasRegistered")){
            self.login.hidden = true
            self.regist.hidden = false
            self.regist.layer.cornerRadius = 0.5 * self.regist.bounds.size.width;
        }else{
            self.regist.hidden = true
            
            self.login.layer.cornerRadius = 0.5 * login.bounds.size.width
            if(self.keychain.getPasscode("GCUsername")! != "" && self.keychain.getPasscode("GCPassword")! != ""){
                if(self.keychain.getPasscode("GCEmail") == ""){
                    print(self.keychain.getPasscode("GCEmail"))
                    makeLoginRequestWithParams(self.keychain.getPasscode("GCUsername")! as String, pass: self.keychain.getPasscode("GCPassword")! as String);
                    print(self.keychain.getPasscode("GCUsername"))
                    print(self.keychain.getPasscode("GCPassword"))
                }else{
                    makeLoginRequestWithParams(self.keychain.getPasscode("GCUsername")as! String, pass: self.keychain.getPasscode("GCPassword")as! String)
                }
            }
            // This could also be another view, connected with an outlet
            
            // Do any additional setup after loading the view.
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func makeLoginRequestWithParams(user : String, pass:String){
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let usernameString = "username=" + user
        print(usernameString)
        let passwordString = "&password=" + pass
        print(passwordString)
        let postData = NSMutableData(data: usernameString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(passwordString.dataUsingEncoding(NSUTF8StringEncoding)!)
        if((NSUserDefaults.standardUserDefaults().objectForKey("id")) != nil){
            let idString = "&id=" + (NSUserDefaults.standardUserDefaults().objectForKey("id") as! String);
            postData.appendData(idString.dataUsingEncoding(NSUTF8StringEncoding)!)
            print("good");
        }
        if((self.keychain.getPasscode("GCEmail")) != ""){
            let emailString = "&email=" + (self.keychain.getPasscode("GCEmail") as! String)
            postData.appendData(emailString.dataUsingEncoding(NSUTF8StringEncoding)!)
            print("in")
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:3000/login")!,
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
                            self.jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray;
                            if(self.keychain.getPasscode("GCPassword") == "" || self.keychain.getPasscode("GCUsername") == ""){
                                self.keychain.setPasscode("GCPassword", passcode: pass)
                                self.keychain.setPasscode("GCUsername", passcode: user)
                            }
                            if (self.loggedIn == false){
                                self.performSegueWithIdentifier("LoginSegue", sender: self)
                                // use anyObj here
                                self.loggedIn = true;
                            }else{
                                
                            }
                        }catch{
                            
                        }
                    })
                }else if (httpResponse?.statusCode == 679){
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Fetty Wap was here");
                        do{
                            self.confirmationDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray;
                            if(self.keychain.getPasscode("GCPassword") == "" || self.keychain.getPasscode("GCUsername") == ""){
                                self.keychain.setPasscode("GCPassword", passcode: pass)
                                self.keychain.setPasscode("GCUsername", passcode: user)
                            }
                            print(self.confirmationDict);
                            let alert = UIAlertController(title: "Who are you?", message: "You've got siblings, so pick who you are.", preferredStyle: .Alert);
                            for object in self.confirmationDict {
                                if((object.objectForKey("username")) != nil){
                                    
                                }else{
                                let id = object.objectForKey("id") as! String;
                                let name = object.objectForKey("name") as! String;
                                let o = UIAlertAction(title: id + " , " + name, style: .Default, handler: {(alert:UIAlertAction!) in
                                    print(id + " " + name)
                                    NSUserDefaults.standardUserDefaults().setObject(id, forKey: "id");
                                    self.makeLoginRequestWithParams(self.keychain.getPasscode("GCUsername") as! String, pass: self.keychain.getPasscode("GCPassword")as! String)
                                    self.updateUser("username", value: id);
                                    self.updateUser("studId", value: self.keychain.getPasscode("GCUsername")as! String);
                                });
                                alert.addAction(o)
                                }
                            }
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        }catch{
                            
                        }
                    })

                }
            }
        })
        
        dataTask.resume()
    }
    
    func updateUser(field : String, value : String){
        print(field + " " + value);
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let string = field + "=" + value;
        print(string)
        let id = "&id=" + (self.confirmationDict[0].objectForKey("_id") as! String)
        let postData = NSMutableData(data: string.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(id.dataUsingEncoding(NSUTF8StringEncoding)!);
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:3000/update")!,
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
                        if(field == "username"){
                            self.keychain.setPasscode("GCEmail", passcode: self.keychain.getPasscode("GCUsername") as! String)
                            self.keychain.setPasscode("GCUsername", passcode: value);
                            
                        }
                    })
                }
            }
        })
        
        dataTask.resume()
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "LoginSegue"){
            let viewcontroller = segue.destinationViewController as! GradeViewController
            viewcontroller.grades = self.jsonDict;
            
        }
    }
    

}
