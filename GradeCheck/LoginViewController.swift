//
//  LoginViewController.swift
//  GradeCheck
//
//  Created by Ivan Chau on 2/21/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, CAAnimationDelegate {
    
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
    let url = "http://gradecheck.herokuapp.com/"
    @IBAction func login(_ sender:UIButton!){
        NSLog("clicked");
        NSLog(usn!.text!);
        NSLog(psw.text!);
        self.usn.resignFirstResponder()
        self.psw.resignFirstResponder()
        if(self.usn.text == "" || self.psw.text == ""){
            let alert = UIAlertController(title: "funni", message: "Are you really?", preferredStyle: .alert);
            let o = UIAlertAction(title: "srry", style: .default, handler: nil);
            alert.addAction(o)
            self.present(alert, animated: true, completion: nil);
            return;
        }else{
            self.activity.isHidden = false
            self.activity.startAnimating()
            self.statusLabel.isHidden = false;
            self.statusLabel.text = "Logging In...";
            UserDefaults.standard.set(self.usn!.text, forKey: "id");
            UserDefaults.standard.set(true, forKey: "shouldUpdateUserToken")
            self.makeLoginRequestWithParams(self.usn.text!, pass: self.psw.text!);
    

        }
    }
    @IBAction func register(_ sender:UIButton!){
        NSLog("clicked");
        NSLog(usn!.text!);
        NSLog(psw.text!);
        self.usn.resignFirstResponder()
        self.psw.resignFirstResponder()
        
        if(self.usn.text == "" || self.psw.text == ""){
            let alert = UIAlertController(title: "funni", message: "Are you really?", preferredStyle: .alert);
            let o = UIAlertAction(title: "srry", style: .default, handler: nil);
            alert.addAction(o)
            self.present(alert, animated: true, completion: nil);
            return;
        }else{
            self.activity.isHidden = false
            self.activity.startAnimating()
            self.statusLabel.isHidden = false;
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
        var postData = NSData(data: usernameString.data(using: String.Encoding.utf8)!) as Data
        postData.append(passwordString.data(using: String.Encoding.utf8)!)
        if(UserDefaults.standard.object(forKey: "userId") != nil){
            let userIdString = "&deviceToken=" + (UserDefaults.standard.object(forKey: "userId") as! String)
            print(userIdString)
            postData.append(userIdString.data(using: String.Encoding.utf8)!)
        }
       
        let request = NSMutableURLRequest(url: URL(string: self.url + "register")!,
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
                        UserDefaults.standard.set(true, forKey: "HasRegistered")
                        UserDefaults.standard.synchronize()
                        self.makeLoginRequestWithParams(self.usn!.text!, pass: self.psw.text!)
                        self.statusLabel.isHidden = false;
                        self.statusLabel.text = "Logging in..."
                    })
                }else if(httpResponse?.statusCode == 912){
                    DispatchQueue.main.async(execute: {
                        print("Authentication incorrect");
                        let alert = UIAlertController(title:"Authentication Error", message:"Please check that your genesis information is correct and register again.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "K", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil);
                        self.statusLabel.text = "";
                        self.statusLabel.isHidden = true;
                        self.activity.stopAnimating();
                        self.activity.isHidden = true;
                    });
                }else{
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertController(title: "An Error Occurred from the Server.", message: "Please try logging in manually, or wait. Status Code :" + String(describing: httpResponse?.statusCode), preferredStyle: .alert);
                        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(alertAction)
                        self.present(alert, animated: true, completion: nil)
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
        image?.draw(in: self.view.bounds)
        UIGraphicsEndImageContext()
        self.loginView.backgroundColor = UIColor(patternImage: image!)
        self.montgomery.image! = (self.montgomery.image?.withRenderingMode(.alwaysTemplate))!
        self.montgomery.tintColor = UIColor(red: 41/255.0, green: 39/255.0, blue: 39/255.0, alpha: 1.0)
        self.statusLabel.isHidden = true;
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        downSwipe.direction = .down;
        self.view.addGestureRecognizer(downSwipe);
        self.executeLogin()
    }
    func executeLogin() {
        if(!UserDefaults.standard.bool(forKey: "HasRegistered")){
            self.overlay.alpha = 0;
            self.login.isHidden = true
            self.regist.isHidden = false
            self.regist.layer.cornerRadius = 0.5 * self.regist.bounds.size.width;
            self.manualLogin.isHidden = false;
            self.manualLogin.layer.cornerRadius = 0.5 * self.manualLogin.bounds.size.width;
        }else{
            self.regist.isHidden = true
            self.manualLogin.isHidden = true;
            self.login.layer.cornerRadius = 0.5 * login.bounds.size.width
            if(self.keychain.getPasscode(identifier: "GCUsername") != nil && self.keychain.getPasscode(identifier: "GCPassword") != nil){
                self.animateLaunch(UIImage(named:"whitespace-montgomery-logo")!, bgColor: UIColor(red: 0.0, green: 0.5019, blue: 0.1529, alpha: 1.0))
                if(self.keychain.getPasscode(identifier: "GCEmail") == ""){
                    print(self.keychain.getPasscode(identifier: "GCEmail"))
                    makeLoginRequestWithParams(self.keychain.getPasscode(identifier: "GCUsername")!, pass: self.keychain.getPasscode(identifier: "GCPassword")! as String);
                    self.activity.isHidden = false
                    self.activity.startAnimating()
                    print(self.keychain.getPasscode(identifier: "GCUsername"))
                    print(self.keychain.getPasscode(identifier: "GCPassword"))
                    self.statusLabel.isHidden = false;
                    self.statusLabel.text = "Loggin in..."
                }else{
                    makeLoginRequestWithParams(self.keychain.getPasscode(identifier: "GCUsername")!, pass: self.keychain.getPasscode(identifier: "GCPassword")!)
                    self.activity.isHidden = false
                    self.activity.startAnimating()
                    self.statusLabel.isHidden = false
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
        if(self.usn.isFirstResponder || self.psw.isFirstResponder){
            self.usn.resignFirstResponder()
            self.psw.resignFirstResponder();
        }
    }
    func animateLaunch(_ image : UIImage, bgColor : UIColor){
        self.view.backgroundColor = bgColor
        mask = CALayer()
        mask.contents = image.cgImage
        mask.bounds = CGRect(x: 0, y: 0, width: 150, height: 150)
        mask.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mask.position = CGPoint(x:self.view.frame.width/2.0, y:self.view.frame.height/2.0)
        mainView.layer.mask = mask;
        
    }
    func animateDecreaseSize(){
        if(mask == nil){
            self.performSegue(withIdentifier: "LoginSegue", sender: self)
        }else{
        let decreaseSize = CABasicAnimation(keyPath:"bounds")
        decreaseSize.delegate = self
        decreaseSize.duration = 0.2
        decreaseSize.fromValue = NSValue(cgRect : mask!.bounds)
        decreaseSize.toValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: 80, height: 80))
        
        decreaseSize.fillMode = kCAFillModeForwards
        decreaseSize.isRemovedOnCompletion = false
        mask.add(decreaseSize, forKey: "bounds")
        }
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if(self.loggedIn){
            animateIncreaseSize()
        }else{
        }
    }
  

    func animateIncreaseSize(){
        animation = CABasicAnimation(keyPath:"bounds")
        animation.duration = 2.0
        animation.fromValue = NSValue(cgRect:mask!.bounds)
        animation.toValue = NSValue(cgRect : CGRect(x: 0, y: 0, width: 2000, height: 2000))
        
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        mask.add(animation, forKey: "bounds")
        
        UIView.animate(withDuration: 1.0, animations: {
            self.overlay.alpha = 0;
            self.mask.opacity = 0.0
            self.mainView.alpha = 0.0
            }, completion: { (complete) in
                UIView.animate(withDuration: 0.75, animations: {
                    self.performSegue(withIdentifier: "LoginSegue", sender: self)
                    /*self.mainView.layer.mask = nil
                    self.mainView.alpha = 1;*/
                })
        }) 
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func makeLoginRequestWithParams(_ user : String, pass:String){
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let usernameString = "username=" + user
        print(usernameString)
        let passwordString = "&password=" + pass
        print(passwordString)
        var postData = NSData(data: usernameString.data(using: String.Encoding.utf8)!) as Data
        postData.append(passwordString.data(using: String.Encoding.utf8)!)
        if((UserDefaults.standard.object(forKey: "id")) != nil){
            let idString = "&id=" + (UserDefaults.standard.object(forKey: "id") as! String);
            postData.append(idString.data(using: String.Encoding.utf8)!)
            print("good");
            print(idString)
        }
        if((self.keychain.getPasscode(identifier: "GCEmail")) != nil){
            let emailString = "&email=" + (self.keychain.getPasscode(identifier: "GCEmail")!)
            postData.append(emailString.data(using: String.Encoding.utf8)!)
            print("in")
        }
        
        let request = NSMutableURLRequest(url: URL(string: url + "login")!,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
                let err = error! as NSError
                if(err.code == -1001){
                    let alert = UIAlertController(title: "Request Timeout", message: "The server can't come to the phone right now.", preferredStyle: .alert)
                    let alertActionCancel = UIAlertAction(title: "Is it dead?", style: .cancel, handler: { (UIAlertAction) in
                        
                    })
                    let alertActionTryAgain = UIAlertAction(title: "Try again.", style: .default, handler: { (UIAlertAction) in
                        self.executeLogin()
                    })
                    alert.addAction(alertActionCancel)
                    alert.addAction(alertActionTryAgain)
                    self.present(alert, animated: true)
                }
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
                if(httpResponse?.statusCode == 200){
                    DispatchQueue.main.async(execute: {
                        do{
                            self.jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray;
                            if(self.keychain.getPasscode(identifier: "GCPassword") == "" || self.keychain.getPasscode(identifier: "GCUsername") == ""){
                                self.keychain.setPasscode(identifier: "GCPassword", passcode: pass)
                                self.keychain.setPasscode(identifier: "GCUsername", passcode: user)
                            }
                            if (self.loggedIn == false){
                                self.activity.stopAnimating()
                                // use anyObj here
                                self.loggedIn = true;
                                self.animateDecreaseSize()
                                self.statusLabel.isHidden = true;
                                self.statusLabel.text = "";
                            }else{
                                
                            }
                            if(UserDefaults.standard.bool(forKey: "shouldUpdateUserToken")){
                                if(UserDefaults.standard.object(forKey: "userId") != nil){
                                    self.updateUser("deviceToken", value: (UserDefaults.standard.object(forKey: "userId") as! String))
                                }
                            }
                            if(UserDefaults.standard.bool(forKey: "HasRegistered") == false){
                                UserDefaults.standard.set(true, forKey: "HasRegistered")
                            }
                        }catch{
                            
                        }
                    })
                }else if (httpResponse?.statusCode == 679){
                    DispatchQueue.main.async(execute: {
                        print("Fetty Wap was here");
                        do{
                            self.confirmationDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSArray;
                            if(self.keychain.getPasscode(identifier: "GCPassword") == "" || self.keychain.getPasscode(identifier: "GCUsername") == ""){
                                self.keychain.setPasscode(identifier: "GCPassword", passcode: pass)
                                self.keychain.setPasscode(identifier: "GCUsername", passcode: user)
                            }
                            print(self.confirmationDict);
                            var alert = UIAlertController();
                            if(self.confirmationDict!.count == 1 ){
                                alert = UIAlertController(title: "Is this you?", message: "", preferredStyle: .alert)
                            }else{
                                alert = UIAlertController(title: "Who are you?", message: "You've got siblings, so pick who you are.", preferredStyle: .alert);
                            }
                            for object in self.confirmationDict! {
                                if(((object as AnyObject).object(forKey: "username")) != nil){
                                    
                                }else{
                                let id = (object as AnyObject).object(forKey: "id") as! String;
                                let name = (object as AnyObject).object(forKey: "name") as! String;
                                let o = UIAlertAction(title: id + " , " + name, style: .default, handler: {(alert:UIAlertAction!) in
                                    print(id + " " + name)
                                    UserDefaults.standard.set(id, forKey: "id");
                                    self.makeLoginRequestWithParams(self.keychain.getPasscode(identifier: "GCUsername")!, pass: self.keychain.getPasscode(identifier: "GCPassword")!)
                                    self.updateUser("username", value: id);
                                    self.updateUser("studId", value: self.keychain.getPasscode(identifier: "GCUsername")!);
                                });
                                alert.addAction(o)
                                }
                            }
                            
                            self.present(alert, animated: true, completion: nil)
                        }catch{
                            
                        }
                    })

                }else{
                    DispatchQueue.main.async(execute: {
                    if(UserDefaults.standard.bool(forKey: "HasRegistered") == false){
                        UserDefaults.standard.set("", forKey: "id")
                    }
                    let alert = UIAlertController(title: "Connection Error:", message: "Incorrect login or server idle. Make sure you have regsitered before. Please try again! Status Code :" +
                        String(httpResponse!.statusCode), preferredStyle: .alert);
                    let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                        self.activity.stopAnimating();
                        self.activity.isHidden = true;
                        self.statusLabel.text = "";
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil);
                    
                    });
                }
            }
        })
        
        dataTask.resume()
    }
    
    func updateUser(_ field : String, value : String){
        self.statusLabel.isHidden = false;
        self.statusLabel.text = "Updating User..."
        print(field + " " + value);
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let string = field + "=" + value;
        print(string)
        
        var postData = NSData(data: string.data(using: String.Encoding.utf8)!) as Data
        if(self.confirmationDict != nil){
            let id = "&id=" + ((self.confirmationDict![0] as AnyObject).object(forKey: "_id") as! String)
            postData.append(id.data(using: String.Encoding.utf8)!);
        }else{
            let dict = self.jsonDict[0] as! NSDictionary
            let objectIDArray = (dict["objectID"] as! [String])
            let id = "&id=" + (objectIDArray[0])
            postData.append(id.data(using: String.Encoding.utf8)!);
        }
        
        
        
        let request = NSMutableURLRequest(url: URL(string: url + "update")!,
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
                print(httpResponse!)
                if(httpResponse?.statusCode == 200){
                    DispatchQueue.main.async(execute: {
                        if(field == "username"){
                            self.keychain.setPasscode(identifier: "GCEmail", passcode: self.keychain.getPasscode(identifier: "GCUsername")!)
                            self.keychain.setPasscode(identifier: "GCUsername", passcode: value);
                            self.statusLabel.isHidden = true;
                            self.statusLabel.text = "";
                        }else if (field == "deviceToken"){
                            UserDefaults.standard.set(true, forKey: "PushNotifs")
                            UserDefaults.standard.set(false, forKey: "shouldUpdateUserToken")
                        }
                    })
                }else if (httpResponse?.statusCode == 1738){
                    DispatchQueue.main.async(execute: {
                      let alert = UIAlertController(title: "Username Taken.", message: "It seems like you've logged on before. Please login with your student id and genesis password to regain access. Thanks!", preferredStyle: .alert)
                        let action = UIAlertAction(title: "10/10", style: .default, handler: nil)
                        alert.addAction(action);
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            }
        })
        
        dataTask.resume()
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "LoginSegue"){
            let viewcontroller = segue.destination as! GradeViewController
            viewcontroller.grades = self.jsonDict;
            if(self.selectedIndex != nil){
                viewcontroller.selectedIndex = self.selectedIndex!;
            }
            
        }
    }
    

}
