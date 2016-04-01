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
    
    var assignments = NSArray()
    var cookie : String!
    var id : String!
    var eventStore = EKEventStore()
    let url = "http://wingster50.ddns.net:2800/"

    override func viewDidLoad() {
        self.id = NSUserDefaults.standardUserDefaults().objectForKey("id") as! String;
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.backgroundColor = UIColor.blackColor()
        self.refreshControl!.tintColor = UIColor.whiteColor()
        self.refreshControl!.addTarget(self, action: #selector(AssignmentsTableViewController.refresh), forControlEvents: UIControlEvents.ValueChanged);

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
                            self.assignments = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray;
                            print(self.assignments)
                            if(self.assignments.count == 0){
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

                }
            }
        })
        
        dataTask.resume()


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
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
                            self.assignments = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray;
                            print(self.assignments)
                            print(self.assignments.count)
                            if(self.assignments.count == 0){
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
        return 1;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return assignments.count;
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AssignmentCell", forIndexPath: indexPath) as! AssignmentsTableViewCell
        let given = self.assignments[indexPath.row] as! NSDictionary;
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

        return cell
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let realCell = cell as! AssignmentsTableViewCell
        realCell.move()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
