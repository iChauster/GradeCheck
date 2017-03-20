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
    //
    //let url = "http://localhost:2800/"
    let url = "http://gradecheck.herokuapp.com/"
    var newAssignments = NSMutableArray()
    var blurEffectView = UIVisualEffectView()
    override var prefersStatusBarHidden : Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "TableSectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "TableSectionHeader")
        self.id = UserDefaults.standard.object(forKey: "id") as! String;
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.backgroundColor = UIColor.black
        self.refreshControl!.tintColor = UIColor.white
        self.refreshControl!.addTarget(self, action: #selector(AssignmentsTableViewController.refresh), for: UIControlEvents.valueChanged);
        let leftSwipe = UISwipeGestureRecognizer(target: self.tabBarController, action: #selector(GradeViewController.swipeLeft))
        leftSwipe.direction = .left
        self.tableView.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self.tabBarController, action: #selector(GradeViewController.swipeRight))
        rightSwipe.direction = .right;
        self.tableView.addGestureRecognizer(rightSwipe)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(AssignmentsTableViewController.handleLongPress))
        self.view.addGestureRecognizer(longPress)
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let cookieString = "cookie=" + self.cookie
        let idString = "&id=" + self.id
        var postData = NSData(data: cookieString.data(using: String.Encoding.utf8)!) as Data
        postData.append(idString.data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: URL(string: url + "assignments")!,
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
                            let array = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray
                            self.assignments = NSMutableArray(array: array)
                            var newArray = Array<Any>();
                            for a in self.assignments {
                                print(a)
                                
                                if let obj = a as? NSDictionary {
                                    
                                
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "M/d/yyyy"
                                
                                    let strDate = obj.object(forKey: "stringDate") as! String
                                    let date = dateFormatter.date(from: strDate)
                                    if(date!.compare(Date()) == .orderedAscending){
                                        print("past");
                                    }else{
                                        newArray.append(obj)
                                        self.newAssignments.add(obj)
                                    }
                                }
                            }
                            self.assignments.removeObjects(in: newArray)
                            print(self.assignments)
                            if(self.assignments.count == 0 && self.newAssignments.count == 0){
                                print("No Assignments")
                                let noView = UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height))
                                noView.backgroundColor = UIColor(red: 0.0, green: 0.5019, blue: 0.2509, alpha: 1.0)
                                let noLabel = UILabel(frame:CGRect(x: 10,y: 0, width: 240,height: 21));
                                noLabel.textAlignment = .center;
                                noLabel.text = "No Assignments :)";
                                noLabel.textColor = UIColor.white
                                noLabel.center = noView.center;
                                noView.addSubview(noLabel)
                                noView.bringSubview(toFront: noLabel)
                                self.tableView.backgroundView = noView;
                            }

                            self.tableView.reloadData()
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


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    func handleLongPress(_ sender: UILongPressGestureRecognizer){
        if (sender.state == .began){
            let touchPoint = sender.location(in: self.view)
            if let indexPath = self.tableView.indexPathForRow(at: touchPoint){
                let cell = self.tableView.cellForRow(at: indexPath) as! AssignmentsTableViewCell
                let blurEffect = UIBlurEffect(style: .light)
                self.blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = self.tableView.bounds;
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.tableView.addSubview(blurEffectView)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let detailvc = storyboard.instantiateViewController(withIdentifier: "AssignmentDetail") as! AssignmentDetailModalViewController
                var assignment = NSDictionary()
                if(indexPath.section == 0){
                    assignment = self.newAssignments[indexPath.row] as! NSDictionary
                }else{
                    assignment = self.assignments[indexPath.row] as! NSDictionary
                }
                detailvc.assignment = assignment
                detailvc.calendarReady = cell.calendarReady
                self.tableView.deselectRow(at: indexPath, animated: true)
                present(detailvc, animated: true, completion: nil)

            }
        }
    }
    func refresh(){
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Hang Tight", attributes: [NSForegroundColorAttributeName:UIColor.white])
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let cookieString = "cookie=" + self.cookie
        let idString = "&id=" + self.id
        var postData = NSData(data: cookieString.data(using: String.Encoding.utf8)!) as Data
        postData.append(idString.data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: URL(string: url + "assignments")!,
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
                            let array = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray;
                            self.assignments = NSMutableArray(array:array)
                            self.newAssignments = [];
                            for a in self.assignments {
                                let obj = a as! NSDictionary
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "M/d/yyyy"
                                let strDate = obj.object(forKey: "stringDate") as! String
                                let date = dateFormatter.date(from: strDate)
                                if(date!.compare(Date()) == .orderedAscending){
                                    print("past");
                                }else{
                                    self.assignments.remove(obj)
                                    self.newAssignments.add(obj)
                                }
                            }
                            if(self.assignments.count == 0 && self.newAssignments.count == 0){
                                print("No Assignments")
                                let noView = UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height))
                                noView.backgroundColor = UIColor(red: 0.0, green: 0.5019, blue: 0.2509, alpha: 1.0)
                                let noLabel = UILabel(frame:CGRect(x: 10,y: 0, width: 240,height: 21));
                                noLabel.textAlignment = .center;
                                noLabel.text = "No Assignments :)";
                                noLabel.textColor = UIColor.white
                                noLabel.center = noView.center;
                                noView.addSubview(noLabel)
                                noView.bringSubview(toFront: noLabel)
                                self.tableView.backgroundView = noView;
                            }
                            self.tableView.reloadData()
                            self.refreshControl?.endRefreshing()
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
            if(section == 0){
                return newAssignments.count
            }else{
                return assignments.count;
            }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentCell", for: indexPath) as! AssignmentsTableViewCell
        var given : NSDictionary = NSDictionary();
        print(self.newAssignments)
        print(self.assignments)
        if(indexPath.section == 0){
            given = self.newAssignments[indexPath.row] as! NSDictionary;
            cell.calendarReady = true;
            let calendarImage = UIImage(named:"calendar.png")
            cell.calendarButton.setImage(calendarImage, for: UIControlState())
        }else{
            given = self.assignments[indexPath.row] as! NSDictionary;
            cell.calendarReady = false;
            let checkImage = UIImage(named:"check.png")
            cell.calendarButton.setImage(checkImage, for: UIControlState());
            cell.calendarButton.setImage(checkImage, for: .selected);


        }
        let assign = given["assignment"]!
        cell.title.text = (assign as AnyObject).object(forKey: "title") as? String;
        cell.detail.text = (assign as AnyObject).object(forKey: "details") as? String;
        cell.course.text = given.object(forKey: "course") as? String;
        var g = given.object(forKey: "percent") as! String;
        cell.date.text = given.object(forKey: "dueDate") as? String;
        cell.dateString = given.object(forKey: "stringDate") as? String;
        cell.grade.grade.text = g
        if(g.contains("%")){
            g = String(g.characters.dropLast());
            let color = UIColor().getColor(grade: Double(g)!)
            cell.grade.backgroundColor = color
        }else{
            cell.grade.backgroundColor = UIColor.black
        }
        cell.backgroundColor = cell.backgroundColor;
        let backgroundView = UIView();
        backgroundView.backgroundColor = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0)
        backgroundView.alpha = 0.8;
        cell.selectedBackgroundView = backgroundView;
        return cell
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let realCell = cell as! AssignmentsTableViewCell
        realCell.move()
        realCell.backgroundColor = realCell.contentView.backgroundColor;
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableSectionHeader")
        let header = cell as! TableSectionHeader
        if(section == 0){
            header.title.text = "UPCOMING"
        }else{
            header.title.text = "DONE"
        }
        return cell;
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
