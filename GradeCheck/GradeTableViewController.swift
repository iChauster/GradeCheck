//
//  GradeTableViewController.swift
//  GradeCheck
//
//  Created by Ivan Chau on 2/21/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class GradeTableViewController: UITableViewController, UIViewControllerTransitioningDelegate {
    
    var gradeArray : NSArray!
    var cookie : String! = "";
    var id : String!
    let url = "http://gradecheck.herokuapp.com/"
    override func viewDidLoad() {
        super.viewDidLoad()
        if(UserDefaults.standard.object(forKey: "GradeTableMP") != nil && UserDefaults.standard.object(forKey: "GradeTableMP") as! String != "MP4"){
            self.gradebookWithMarkingPeriod(UserDefaults.standard.object(forKey: "GradeTableMP") as! String);
        }
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.backgroundColor = UIColor.black
        self.refreshControl!.tintColor = UIColor.white
        self.refreshControl!.addTarget(self, action: #selector(GradeTableViewController.refresh), for: UIControlEvents.valueChanged);
        let leftSwipe = UISwipeGestureRecognizer.init(target: self.tabBarController, action: #selector(GradeViewController.swipeLeft))
        leftSwipe.direction = .left
        self.tableView.addGestureRecognizer(leftSwipe);
        let rightSwipe = UISwipeGestureRecognizer.init(target:self.tabBarController, action: #selector(GradeViewController.swipeRight))
        self.tableView.addGestureRecognizer(rightSwipe)
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0,0, 0)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(GradeTableViewController.markingPeriodSwitch))
        self.tableView.addGestureRecognizer(longPress)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    var openingFrame : CGRect?
    override var prefersStatusBarHidden : Bool {
        return true;
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let presentationAnimator = ExpandAnimator.animator
        presentationAnimator.openingFrame = openingFrame!
        presentationAnimator.transitionMode = .present;
        return presentationAnimator
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let presentationAnimator = ExpandAnimator.animator
        presentationAnimator.openingFrame = openingFrame!
        presentationAnimator.transitionMode = .dismiss;
        return presentationAnimator
    }
    func markingPeriodSwitch(_ sender:UILongPressGestureRecognizer){
        print("longPress:",sender.state.rawValue);
        if(sender.state == .began){
            let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds;
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.view.addSubview(blurEffectView)
            let alert = UIAlertController(title: "MP?", message: "What marking period would you like to view?", preferredStyle: .alert)
            let mp1 = UIAlertAction(title: "Marking Period 1", style: .default) { (alert:UIAlertAction!) in
                print("mp1 clicked");
                UserDefaults.standard.set("MP1", forKey: "GradeTableMP")
                self.gradebookWithMarkingPeriod(UserDefaults.standard.object(forKey: "GradeTableMP") as! String);
                blurEffectView.removeFromSuperview();
            }
            let mp2 = UIAlertAction(title: "Marking Period 2", style: .default) { (alert:UIAlertAction!) in
                print("mp1 clicked");
                UserDefaults.standard.set("MP2", forKey: "GradeTableMP")
                self.gradebookWithMarkingPeriod(UserDefaults.standard.object(forKey: "GradeTableMP") as! String);
                blurEffectView.removeFromSuperview();

            }
            let mp3 = UIAlertAction(title: "Marking Period 3", style: .default) { (alert:UIAlertAction!) in
                print("mp1 clicked");
                UserDefaults.standard.set("MP3", forKey: "GradeTableMP")
                self.gradebookWithMarkingPeriod(UserDefaults.standard.object(forKey: "GradeTableMP") as! String);
                blurEffectView.removeFromSuperview();

            }
            let mp4 = UIAlertAction(title: "Marking Period 4", style: .default) { (alert:UIAlertAction!) in
                print("mp1 clicked");
                UserDefaults.standard.set("MP4", forKey: "GradeTableMP")
                self.gradebookWithMarkingPeriod(UserDefaults.standard.object(forKey: "GradeTableMP") as! String);
                blurEffectView.removeFromSuperview();
            }
            let cancel = UIAlertAction(title:"Cancel", style: .cancel){(alert:UIAlertAction!) in
                print("cancelled");
                blurEffectView.removeFromSuperview();
            }
            alert.addAction(mp1);
            alert.addAction(mp2);
            alert.addAction(mp3);
            alert.addAction(mp4);
            alert.addAction(cancel);
            self.present(alert, animated: true, completion: nil);
            
        }else{
            print("n/a")
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return gradeArray.count - 1;
    }
    func gradebookWithMarkingPeriod(_ mp : String){
        if(self.cookie == ""){
            let cookieID = gradeArray[0] as! NSDictionary
            let cookieArray = cookieID.object(forKey: "cookie") as? NSArray
            self.cookie = cookieArray![0] as? String;
        }
        self.id = UserDefaults.standard.object(forKey: "id") as! String;
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let cookieString = "cookie=" + self.cookie
        let idString = "&id=" + self.id
        let mpString = "&mp=" + mp;
        var postData = NSData(data: cookieString.data(using: String.Encoding.utf8)!) as Data
        postData.append(idString.data(using: String.Encoding.utf8)!)
        postData.append(mpString.data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: URL(string: url + "gradebook")!,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
                if(httpResponse?.statusCode == 200){
                    DispatchQueue.main.async(execute: {
                        do{
                            self.gradeArray = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray;
                            self.tableView.reloadData()
                            self.refreshControl?.endRefreshing()
                            let gradeView = self.tabBarController as! GradeViewController
                            gradeView.grades = self.gradeArray
                            let statView = gradeView.viewControllers![2] as! StatViewController
                            statView.gradesArray = self.gradeArray
                            
                        }catch{
                            
                        }
                    })
                    
                }else if(httpResponse?.statusCode == 440){
                    DispatchQueue.main.async(execute: {
                        do{
                            let cookie = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray;
                            print(cookie);
                            let cooke = cookie[0] as! NSDictionary
                            let hafl = cooke.object(forKey: "set-cookie") as! NSArray;
                            self.cookie = hafl[0] as! String;
                            print(self.cookie);
                            self.tabBarController?.perform(#selector(GradeViewController.refreshAndLogin), with: self.cookie)
                            self.refreshControl?.endRefreshing()
                        }catch{
                            
                        }
                    })
                    
                }
            }
        })
        
        dataTask.resume()
    }
    
    func refresh(){
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Hang Tight", attributes: [NSForegroundColorAttributeName:UIColor.white])
        print("refreshing....")
        if(self.cookie == ""){
            let cookieID = gradeArray[0] as! NSDictionary;
            let cookieArray = cookieID.object(forKey: "cookie") as? NSArray;
            self.cookie = cookieArray![0] as? String;
            print("No cookie, finding from array")
        }else{
            print("Cookie, it's " + self.cookie);
        }
        
        self.id = UserDefaults.standard.object(forKey: "id") as! String;
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let cookieString = "cookie=" + self.cookie
        let idString = "&id=" + self.id
        var postData = NSData(data: cookieString.data(using: String.Encoding.utf8)!) as Data
        if(UserDefaults.standard.object(forKey: "GradeTableMP") != nil && UserDefaults.standard.object(forKey: "GradeTableMP") as! String != "MP4"){
            let mp = UserDefaults.standard.object(forKey: "GradeTableMP") as! String;
            let mpString = "&mp=" + mp;
            postData.append(mpString.data(using: String.Encoding.utf8)!)
        }
        postData.append(idString.data(using: String.Encoding.utf8)!)
    
        let request = NSMutableURLRequest(url: URL(string: url + "gradebook")!,
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
                            self.gradeArray = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray;
                            self.tableView.reloadData()
                            self.refreshControl?.endRefreshing()
                            let gradeView = self.tabBarController as! GradeViewController
                            gradeView.grades = self.gradeArray
                            let statView = gradeView.viewControllers![2] as! StatViewController
                            statView.gradesArray = self.gradeArray
                        }catch{
                            
                        }
                    })
                    
                }else if(httpResponse?.statusCode == 440){
                    DispatchQueue.main.async(execute: {
                        do{
                            let cookie = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray;
                            print(cookie);
                            let cooke = cookie[0] as! NSDictionary
                            let hafl = cooke.object(forKey: "set-cookie") as! NSArray;
                            self.cookie = hafl[0] as! String;
                            print(self.cookie);
                            self.tabBarController?.perform(#selector(GradeViewController.refreshAndLogin), with: self.cookie)
                            self.refreshControl?.endRefreshing()
                        }catch{
                            
                        }
                    })

                }
            }
        })
    
        dataTask.resume()
        


        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell", for: indexPath) as! GradeTableViewCell;
        let element = gradeArray[indexPath.row + 1] as! NSDictionary;
        cell.classg.text = element.object(forKey: "class") as? String;
        cell.grade.text = element.object(forKey: "grade") as? String;
        cell.teacher.text = element.object(forKey: "teacher") as? String;
        var g = element.object(forKey: "grade") as! String;
        if(g.contains("%")){
            g = String(g.characters.dropLast());
            let color = UIColor().getColor(grade: Double(g)!)
            cell.views.backgroundColor = color
            cell.color = color
            cell.percent = Int(g)
        }else{
            cell.views.backgroundColor = UIColor.black
            cell.color = UIColor.black
            cell.percent = -1;
        }
        cell.backgroundColor = cell.backgroundColor;
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0.3647, green: 0.8431, blue: 0.3176, alpha: 1.0);
        backgroundView.alpha = 0.0;
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let attributesFrame = tableView.cellForRow(at: indexPath);
        let attribute = attributesFrame?.frame;
        let frameToOpenFrame = tableView.convert(attribute!, to: tableView.superview)
        openingFrame = frameToOpenFrame
        print(openingFrame?.debugDescription)
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let expandedvc = storyboard.instantiateViewController(withIdentifier: "DetailGradeViewController") as! DetailGradeViewController
        expandedvc.transitioningDelegate = self
        expandedvc.modalPresentationStyle = .custom

        let selectedCell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! GradeTableViewCell
        expandedvc.data = self.gradeArray[(self.tableView.indexPathForSelectedRow?.row)! + 1] as! NSDictionary
        expandedvc.color = selectedCell.color;
        expandedvc.cookieData = self.gradeArray[0] as! NSDictionary
        expandedvc.whole = self.gradeArray;
        expandedvc.gradeFrame = openingFrame
        //expandedvc.classtitle = selectedCell.classg.text! + " - " + selectedCell.grade.text!;
        expandedvc.classtitle = selectedCell.classg.text!
        expandedvc.classGrade = String(selectedCell.percent) + "%"
        expandedvc.classTeacher = selectedCell.teacher.text!
        expandedvc.markingPeriod = UserDefaults.standard.object(forKey: "GradeTableMP") as? String
        self.tableView.deselectRow(at: indexPath, animated: true)
        present(expandedvc, animated: true, completion: nil)
        
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let actualCell = cell as! GradeTableViewCell
        CellAnimation.animate(actualCell);
        if(actualCell.percent != -1){
            actualCell.grade.animationCurve = PercentLabelAnimationCurve.easeInOut
            actualCell.grade.count(from: 0, to: CGFloat(actualCell.percent), duration: 1.0)
        }
        actualCell.backgroundColor = actualCell.contentView.backgroundColor;
        UIView.animate(withDuration: 1.0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            actualCell.views.backgroundColor = actualCell.color
            }) { (complete) in
                
        }
    }
    /*override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("GradeSegue", sender: self);
    }*/
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "GradeSegue"){
            
            let selectedCell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! GradeTableViewCell
    
            let viewcontroller = segue.destination as! DetailGradeViewController
            
            viewcontroller.data = self.gradeArray[(self.tableView.indexPathForSelectedRow?.row)! + 1] as! NSDictionary
            viewcontroller.color = selectedCell.color;
            viewcontroller.cookieData = self.gradeArray[0] as! NSDictionary
            viewcontroller.whole = self.gradeArray;
            viewcontroller.classtitle = selectedCell.classg.text! + " - " + selectedCell.grade.text!;
            viewcontroller.markingPeriod = UserDefaults.standard.object(forKey: "GradeTableMP") as? String
        }
    }
 
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    */

}
