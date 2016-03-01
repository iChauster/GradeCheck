//
//  GradeTableViewController.swift
//  GradeCheck
//
//  Created by Ivan Chau on 2/21/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class GradeTableViewController: UITableViewController {
    
    var gradeArray : NSArray!
    var cookie : String!
    var id : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(gradeArray)
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.backgroundColor = UIColor.blackColor()
        self.refreshControl!.tintColor = UIColor.whiteColor()
        self.refreshControl!.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged);
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return gradeArray.count - 1;
    }

    func refresh(){
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Hang Tight", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        print("refreshing....")
        let cookieID = gradeArray[0] as! NSDictionary;
        let cookieArray = cookieID.objectForKey("cookie") as? NSArray;
        self.cookie = cookieArray![0] as? String;
        self.id = cookieID.objectForKey("id") as? String;
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let cookieString = "cookie=" + self.cookie
        let idString = "&id=" + self.id
        let postData = NSMutableData(data: cookieString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(idString.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:3000/gradebook")!,
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
                            self.gradeArray = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray;
                            print(self.gradeArray)
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
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ClassCell", forIndexPath: indexPath) as! GradeTableViewCell;
        let element = gradeArray[indexPath.row + 1] as! NSDictionary;
        cell.classg.text = element.objectForKey("class") as? String;
        cell.grade.text = element.objectForKey("grade") as? String;
        cell.teacher.text = element.objectForKey("teacher") as? String;
        var g = element.objectForKey("grade") as! String;
        if(g.containsString("%")){
            g = String(g.characters.dropLast());
            switch Int(g)!{
            case 0..<50:
                cell.views.backgroundColor = UIColor.blackColor()
            case 51..<75 :
                cell.views.backgroundColor = UIColor.redColor()
            case 76..<85 :
                cell.views.backgroundColor = UIColor.yellowColor()
            case 86..<110 :
                cell.views.backgroundColor = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0);
            default :
                cell.views.backgroundColor = UIColor.purpleColor()
            }
        }else{
            cell.views.backgroundColor = UIColor.blackColor()
        }
        return cell
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        CellAnimation.animate(cell);
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
