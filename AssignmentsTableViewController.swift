//
//  AssignmentsTableViewController.swift
//  GradeCheck
//
//  Created by Ivan Chau on 2/21/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit
import EventKit

class AssignmentsTableViewController: UITableViewController {
    
    var assignments = NSMutableArray()
    var cookie : String!
    var id : String!
    var eventStore = EKEventStore()
    let url = "https://gradecheck.herokuapp.com/"
    var newAssignments = NSMutableArray()
    var blurEffectView = UIVisualEffectView()
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "TableSectionHeader", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "TableSectionHeader")
        self.id = NSUserDefaults.standardUserDefaults().objectForKey("id") as! String;
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.backgroundColor = UIColor.blackColor()
        self.refreshControl!.tintColor = UIColor.whiteColor()
        self.refreshControl!.addTarget(self, action: #selector(AssignmentsTableViewController.refresh), forControlEvents: UIControlEvents.ValueChanged);
        let leftSwipe = UISwipeGestureRecognizer(target: self.tabBarController, action: #selector(GradeViewController.swipeLeft))
        leftSwipe.direction = .Left
        self.tableView.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self.tabBarController, action: #selector(GradeViewController.swipeRight))
        rightSwipe.direction = .Right;
        self.tableView.addGestureRecognizer(rightSwipe)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(AssignmentsTableViewController.handleLongPress))
        self.view.addGestureRecognizer(longPress)
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let cookieString = "cookie=" + self.cookie
        let idString = "&id=" + self.id
        let postData = NSMutableData(data: cookieString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(idString.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let request = NSMutableURLRequest(URL: NSURL(string: url + "assignments")!,
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
                            let array = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray;
                            self.assignments = NSMutableArray(array: array)
                            for obj in self.assignments {
                                let dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = "M/d/yyyy"
                                let strDate = obj.objectForKey("stringDate") as! String
                                let date = dateFormatter.dateFromString(strDate)
                                if(date!.compare(NSDate()) == .OrderedAscending){
                                    print("past");
                                }else{
                                    self.assignments.removeObject(obj)
                                    self.newAssignments.addObject(obj)
                                }
                            }
                            print(self.assignments)
                            if(self.assignments.count == 0 && self.newAssignments == 0){
                                print("No Assignments")
                                let noView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height))
                                noView.backgroundColor = UIColor(red: 0.0, green: 0.5019, blue: 0.2509, alpha: 1.0)
                                let noLabel = UILabel(frame:CGRectMake(10,0, 240,21));
                                noLabel.textAlignment = .Center;
                                noLabel.text = "No Assignments :)";
                                noLabel.textColor = UIColor.whiteColor()
                                noLabel.center = noView.center;
                                noView.addSubview(noLabel)
                                noView.bringSubviewToFront(noLabel)
                                self.tableView.backgroundView = noView;
                            }

                            self.tableView.reloadData()
                        }catch{
                            
                        }
                    })

                }else if(httpResponse?.statusCode == 440){
                    dispatch_async(dispatch_get_main_queue(), {
                        do{
                            let cookie = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray;
                            print(cookie);
                            let cooke = cookie[0] as! NSDictionary
                            let hafl = cooke.objectForKey("set-cookie") as! NSArray;
                            self.cookie = hafl[0] as! String;
                            print(self.cookie);
                            self.tabBarController?.performSelector(#selector(GradeViewController.refreshAndLogin), withObject: self.cookie)
                            self.refreshControl?.endRefreshing()
                        }catch{
                            
                        }
                    })

                }
            }
        })
        
        dataTask.resume()


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    func handleLongPress(sender: UILongPressGestureRecognizer){
        if (sender.state == .Began){
            let touchPoint = sender.locationInView(self.view)
            if let indexPath = self.tableView.indexPathForRowAtPoint(touchPoint){
                let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! AssignmentsTableViewCell
                let blurEffect = UIBlurEffect(style: .Light)
                self.blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = self.view.bounds;
                blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                self.tableView.addSubview(blurEffectView)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let detailvc = storyboard.instantiateViewControllerWithIdentifier("AssignmentDetail") as! AssignmentDetailModalViewController
                var assignment = NSDictionary()
                if(indexPath.section == 0){
                    assignment = self.newAssignments[indexPath.row] as! NSDictionary
                }else{
                    assignment = self.assignments[indexPath.row] as! NSDictionary
                }
                detailvc.assignment = assignment
                detailvc.calendarReady = cell.calendarReady
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                presentViewController(detailvc, animated: true, completion: nil)

            }
        }
    }
    func refresh(){
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Hang Tight", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let cookieString = "cookie=" + self.cookie
        let idString = "&id=" + self.id
        let postData = NSMutableData(data: cookieString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(idString.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let request = NSMutableURLRequest(URL: NSURL(string: url + "assignments")!,
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
                            let array = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray;
                            self.assignments = NSMutableArray(array:array)
                            self.newAssignments = [];
                            for obj in self.assignments {
                                let dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = "M/d/yyyy"
                                let strDate = obj.objectForKey("stringDate") as! String
                                let date = dateFormatter.dateFromString(strDate)
                                if(date!.compare(NSDate()) == .OrderedAscending){
                                    print("past");
                                }else{
                                    self.assignments.removeObject(obj)
                                    self.newAssignments.addObject(obj)
                                }
                            }
                            if(self.assignments.count == 0 && self.newAssignments.count == 0){
                                print("No Assignments")
                                let noView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height))
                                noView.backgroundColor = UIColor(red: 0.0, green: 0.5019, blue: 0.2509, alpha: 1.0)
                                let noLabel = UILabel(frame:CGRectMake(10,0, 240,21));
                                noLabel.textAlignment = .Center;
                                noLabel.text = "No Assignments :)";
                                noLabel.textColor = UIColor.whiteColor()
                                noLabel.center = noView.center;
                                noView.addSubview(noLabel)
                                noView.bringSubviewToFront(noLabel)
                                self.tableView.backgroundView = noView;
                            }
                            self.tableView.reloadData()
                            self.refreshControl?.endRefreshing()
                        }catch{
                            
                        }
                    })
                    
                }else if(httpResponse?.statusCode == 440){
                    dispatch_async(dispatch_get_main_queue(), {
                        do{
                            let cookie = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray;
                            print(cookie);
                            let cooke = cookie[0] as! NSDictionary
                            let hafl = cooke.objectForKey("set-cookie") as! NSArray;
                            self.cookie = hafl[0] as! String;
                            print(self.cookie);
                            self.tabBarController?.performSelector(#selector(GradeViewController.refreshAndLogin), withObject: self.cookie)
                            self.refreshControl?.endRefreshing()
                        }catch{
                            
                        }
                    })

                }
            }
        })
        
        dataTask.resume()
        

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
            if(section == 0){
                return newAssignments.count
            }else{
                return assignments.count;
            }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AssignmentCell", forIndexPath: indexPath) as! AssignmentsTableViewCell
        var given : NSDictionary = NSDictionary();
        print(self.newAssignments)
        print(self.assignments)
        if(indexPath.section == 0){
            given = self.newAssignments[indexPath.row] as! NSDictionary;
            cell.calendarReady = true;
            let calendarImage = UIImage(named:"calendar.png")
            cell.calendarButton.setImage(calendarImage, forState: .Normal)
        }else{
            given = self.assignments[indexPath.row] as! NSDictionary;
            cell.calendarReady = false;
            let checkImage = UIImage(named:"check.png")
            cell.calendarButton.setImage(checkImage, forState: .Normal);
            cell.calendarButton.setImage(checkImage, forState: .Selected);


        }
        let assign = given["assignment"]!
        cell.title.text = assign.objectForKey("title") as? String;
        cell.detail.text = assign.objectForKey("details") as? String;
        cell.course.text = given.objectForKey("course") as? String;
        var g = given.objectForKey("percent") as! String;
        cell.date.text = given.objectForKey("dueDate") as? String;
        cell.dateString = given.objectForKey("stringDate") as? String;
        cell.grade.grade.text = g
        if(g.containsString("%")){
            g = String(g.characters.dropLast());
            switch Double(g)!{
            case 0..<50:
                cell.grade.backgroundColor = UIColor.blackColor()
            case 51..<75 :
                cell.grade.backgroundColor = UIColor.redColor()
            case 76..<85 :
                cell.grade.backgroundColor = UIColor.yellowColor()
            case 86..<110 :
                cell.grade.backgroundColor = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0);
                
            default :
                cell.grade.backgroundColor = UIColor.purpleColor()
            }
        }else{
            cell.grade.backgroundColor = UIColor.blackColor()
        }
        cell.backgroundColor = cell.backgroundColor;
        let backgroundView = UIView();
        backgroundView.backgroundColor = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0)
        backgroundView.alpha = 0.8;
        cell.selectedBackgroundView = backgroundView;
        return cell
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let realCell = cell as! AssignmentsTableViewCell
        realCell.move()
        realCell.backgroundColor = realCell.contentView.backgroundColor;
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("TableSectionHeader")
        let header = cell as! TableSectionHeader
        if(section == 0){
            header.title.text = "UPCOMING"
        }else{
            header.title.text = "DONE"
        }
        return cell;
    }
    func ridOfBlur() {
        self.blurEffectView.removeFromSuperview()
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
