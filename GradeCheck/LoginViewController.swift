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
    @IBOutlet weak var activity : UIActivityIndicatorView!
    @IBOutlet weak var statusLabel : UILabel!
    @IBOutlet weak var manualLogin : UIButton!
    @IBOutlet weak var montgomery : UIImageView!
    @IBOutlet weak var mainView : UIView!
    @IBOutlet weak var loginView : UIView!
    @IBOutlet weak var overlay : UIView!
    
    var mask : CALayer!
    var animation : CABasicAnimation!
    let keychain = Keychain()
    var jsonDict : NSArray!
    var confirmationDict : NSArray?
    var loggedIn : Bool = false;
    var phoneNumberOption : String?
    var selectedIndex : Int?
    let url = "http://localhost:2800/"
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
            self.activity.hidden = false
            self.activity.startAnimating()
            self.statusLabel.hidden = false;
            self.statusLabel.text = "Logging In...";
            NSUserDefaults.standardUserDefaults().setObject(self.usn!.text, forKey: "id");
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shouldUpdateUserToken")
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
            self.activity.hidden = false
            self.activity.startAnimating()
            self.statusLabel.hidden = false;
            self.statusLabel.text = "Registering...";
            self.makeRegisterRequest()
        }
    }
    func makeRegisterRequest(){
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let usernameString = "username=" + self.usn!.text!
        let passwordString = "&password=" + self.psw.text!
        let postData = NSMutableData(data: usernameString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(passwordString.dataUsingEncoding(NSUTF8StringEncoding)!)
        if(NSUserDefaults.standardUserDefaults().objectForKey("userId") != nil){
            let userIdString = "&deviceToken=" + (NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String)
            print(userIdString)
            postData.appendData(userIdString.dataUsingEncoding(NSUTF8StringEncoding)!)
        }
       
        let request = NSMutableURLRequest(URL: NSURL(string: self.url + "register")!,
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
                        self.statusLabel.hidden = false;
                        self.statusLabel.text = "Logging in..."
                    })
                }else if(httpResponse?.statusCode == 912){
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Authentication incorrect");
                        let alert = UIAlertController(title:"Authentication Error", message:"Please check that your genesis information is correct and register again.", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "K", style: .Default, handler: nil)
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil);
                        self.statusLabel.text = "";
                        self.statusLabel.hidden = true;
                        self.activity.stopAnimating();
                        self.activity.hidden = true;
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(),{
                        let alert = UIAlertController(title: "An Error Occurred from the Server.", message: "Please try logging in manually, or wait. Status Code :" + String(httpResponse?.statusCode), preferredStyle: .Alert);
                        let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alert.addAction(alertAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
            }
        })
        
        dataTask.resume()

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        UIGraphicsBeginImageContext(self.view.frame.size);
        let image = UIImage(named: "back1.png")
        image?.drawInRect(self.view.bounds)
        UIGraphicsEndImageContext()
        self.loginView.backgroundColor = UIColor(patternImage: image!)
        self.montgomery.image! = (self.montgomery.image?.imageWithRenderingMode(.AlwaysTemplate))!
        self.montgomery.tintColor = UIColor(red: 41/255.0, green: 39/255.0, blue: 39/255.0, alpha: 1.0)
        self.statusLabel.hidden = true;
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        downSwipe.direction = .Down;
        self.view.addGestureRecognizer(downSwipe);
        if(!NSUserDefaults.standardUserDefaults().boolForKey("HasRegistered")){
            self.overlay.alpha = 0;
            self.login.hidden = true
            self.regist.hidden = false
            self.regist.layer.cornerRadius = 0.5 * self.regist.bounds.size.width;
            self.manualLogin.hidden = false;
            self.manualLogin.layer.cornerRadius = 0.5 * self.manualLogin.bounds.size.width;
        }else{
            self.regist.hidden = true
            self.manualLogin.hidden = true;
            self.login.layer.cornerRadius = 0.5 * login.bounds.size.width
            if(self.keychain.getPasscode("GCUsername")! != "" && self.keychain.getPasscode("GCPassword")! != ""){
                self.animateLaunch(UIImage(named:"whitespace-montgomery-logo")!, bgColor: UIColor(red: 0.0, green: 0.5019, blue: 0.1529, alpha: 1.0))
                if(self.keychain.getPasscode("GCEmail") == ""){
                    print(self.keychain.getPasscode("GCEmail"))
                    makeLoginRequestWithParams(self.keychain.getPasscode("GCUsername")! as String, pass: self.keychain.getPasscode("GCPassword")! as String);
                    self.activity.hidden = false
                    self.activity.startAnimating()
                    print(self.keychain.getPasscode("GCUsername"))
                    print(self.keychain.getPasscode("GCPassword"))
                    self.statusLabel.hidden = false;
                    self.statusLabel.text = "Loggin in..."
                }else{
                    makeLoginRequestWithParams(self.keychain.getPasscode("GCUsername")as! String, pass: self.keychain.getPasscode("GCPassword")as! String)
                    self.activity.hidden = false
                    self.activity.startAnimating()
                    self.statusLabel.hidden = false
                    self.statusLabel.text = "Logging in..."
                }
                /*if(NSUserDefaults.standardUserDefaults().boolForKey("shouldUpdateUserToken")){
                    print("should update User Token");
                    self.updateUser("deviceToken", value: (NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String))
                }*/
            }
            // This could also be another view, connected with an outlet
            
            // Do any additional setup after loading the view.
        }
    }
    func dismissKeyboard(){
        if(self.usn.isFirstResponder() || self.psw.isFirstResponder()){
            self.usn.resignFirstResponder()
            self.psw.resignFirstResponder();
        }
    }
    func animateLaunch(image : UIImage, bgColor : UIColor){
        self.view.backgroundColor = bgColor
        mask = CALayer()
        mask.contents = image.CGImage
        mask.bounds = CGRect(x: 0, y: 0, width: 150, height: 150)
        mask.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mask.position = CGPoint(x:self.view.frame.width/2.0, y:self.view.frame.height/2.0)
        mainView.layer.mask = mask;
        
    }
    func animateDecreaseSize(){
        if(mask == nil){
            self.performSegueWithIdentifier("LoginSegue", sender: self)
        }else{
        let decreaseSize = CABasicAnimation(keyPath:"bounds")
        decreaseSize.delegate = self
        decreaseSize.duration = 0.2
        decreaseSize.fromValue = NSValue(CGRect : mask!.bounds)
        decreaseSize.toValue = NSValue(CGRect: CGRect(x: 0, y: 0, width: 80, height: 80))
        
        decreaseSize.fillMode = kCAFillModeForwards
        decreaseSize.removedOnCompletion = false
        mask.addAnimation(decreaseSize, forKey: "bounds")
        }
    }
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if(self.loggedIn){
            animateIncreaseSize()
        }else{
        }
    }
  

    func animateIncreaseSize(){
        animation = CABasicAnimation(keyPath:"bounds")
        animation.duration = 2.0
        animation.fromValue = NSValue(CGRect:mask!.bounds)
        animation.toValue = NSValue(CGRect : CGRect(x: 0, y: 0, width: 2000, height: 2000))
        
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        
        mask.addAnimation(animation, forKey: "bounds")
        
        UIView.animateWithDuration(1.0, animations: {
            self.overlay.alpha = 0;
            self.mask.opacity = 0.0
            self.mainView.alpha = 0.0
            }) { (complete) in
                UIView.animateWithDuration(0.75, animations: {
                    self.performSegueWithIdentifier("LoginSegue", sender: self)
                    /*self.mainView.layer.mask = nil
                    self.mainView.alpha = 1;*/
                })
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
        
        let request = NSMutableURLRequest(URL: NSURL(string: url + "sss")!,
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
                                self.activity.stopAnimating()
                                // use anyObj here
                                self.loggedIn = true;
                                self.animateDecreaseSize()
                                self.statusLabel.hidden = true;
                                self.statusLabel.text = "";
                            }else{
                                
                            }
                            if(NSUserDefaults.standardUserDefaults().boolForKey("shouldUpdateUserToken")){
                                if(NSUserDefaults.standardUserDefaults().objectForKey("userId") != nil){
                                    self.updateUser("deviceToken", value: (NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String))
                                }
                            }
                            if(NSUserDefaults.standardUserDefaults().boolForKey("HasRegistered") == false){
                                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasRegistered")
                            }
                        }catch{
                            
                        }
                    })
                }else if (httpResponse?.statusCode == 679){
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Fetty Wap was here");
                        do{
                            self.confirmationDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSArray;
                            if(self.keychain.getPasscode("GCPassword") == "" || self.keychain.getPasscode("GCUsername") == ""){
                                self.keychain.setPasscode("GCPassword", passcode: pass)
                                self.keychain.setPasscode("GCUsername", passcode: user)
                            }
                            print(self.confirmationDict);
                            var alert = UIAlertController();
                            if(self.confirmationDict!.count == 1 ){
                                alert = UIAlertController(title: "Is this you?", message: "", preferredStyle: .Alert)
                            }else{
                                alert = UIAlertController(title: "Who are you?", message: "You've got siblings, so pick who you are.", preferredStyle: .Alert);
                            }
                            for object in self.confirmationDict! {
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

                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                    if(NSUserDefaults.standardUserDefaults().boolForKey("HasRegistered") == false){
                        NSUserDefaults.standardUserDefaults().setObject("", forKey: "id")
                    }
                    let alert = UIAlertController(title: "Connection Error:", message: "Incorrect login or server idle. Make sure you have regsitered before. Please try again! Status Code :" +
                        String(httpResponse!.statusCode), preferredStyle: .Alert);
                    let action = UIAlertAction(title: "OK", style: .Default, handler: { (alert) in
                        self.activity.stopAnimating();
                        self.activity.hidden = true;
                        self.statusLabel.text = "";
                    })
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil);
                    
                    });
                }
            }
        })
        
        dataTask.resume()
    }
    
    func updateUser(field : String, value : String){
        self.statusLabel.hidden = false;
        self.statusLabel.text = "Updating User..."
        print(field + " " + value);
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let string = field + "=" + value;
        print(string)
        
        let postData = NSMutableData(data: string.dataUsingEncoding(NSUTF8StringEncoding)!)
        if(self.confirmationDict != nil){
            let id = "&id=" + (self.confirmationDict![0].objectForKey("_id") as! String)
            postData.appendData(id.dataUsingEncoding(NSUTF8StringEncoding)!);
        }else{
            let objectIDArray = (self.jsonDict[0]["objectID"] as! [String])
            let id = "&id=" + (objectIDArray[0])
            postData.appendData(id.dataUsingEncoding(NSUTF8StringEncoding)!);
        }
        
        
        
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
                        if(field == "username"){
                            self.keychain.setPasscode("GCEmail", passcode: self.keychain.getPasscode("GCUsername") as! String)
                            self.keychain.setPasscode("GCUsername", passcode: value);
                            self.statusLabel.hidden = true;
                            self.statusLabel.text = "";
                        }else if (field == "deviceToken"){
                            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "PushNotifs")
                            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "shouldUpdateUserToken")
                        }
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
            if(self.selectedIndex != nil){
                viewcontroller.selectedIndex = self.selectedIndex!;
            }
            
        }
    }
    

}
