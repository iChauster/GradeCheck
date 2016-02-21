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
    let keychain = Keychain()
    var jsonDict : NSArray!
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
    override func viewDidLoad() {
        super.viewDidLoad()
        UIGraphicsBeginImageContext(self.view.frame.size);
        let image = UIImage(named: "back1.png")
        image?.drawInRect(self.view.bounds)
        UIGraphicsEndImageContext()
        self.login.layer.cornerRadius = 0.5 * login.bounds.size.width
        if(self.keychain.getPasscode("GCUsername")! != "" && self.keychain.getPasscode("GCPassword")! != ""){
            makeLoginRequestWithParams(self.keychain.getPasscode("GCUsername")! as String, pass: self.keychain.getPasscode("GCPassword")! as String);
            print(self.keychain.getPasscode("GCUsername"))
            print(self.keychain.getPasscode("GCPassword"))
        }
        // This could also be another view, connected with an outlet
        self.view.backgroundColor = UIColor(patternImage: image!)
        // Do any additional setup after loading the view.
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
        let passwordString = "&password=" + pass
        let postData = NSMutableData(data: usernameString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(passwordString.dataUsingEncoding(NSUTF8StringEncoding)!)
        
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
                            print(self.jsonDict);
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
                }
            }
        })
        
        dataTask.resume()
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
