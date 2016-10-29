//
//  DetailGradeViewController.swift
//  GradeCheck
//
//  Created by Ivan Chau on 3/23/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class DetailGradeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UIViewControllerPreviewingDelegate {
    var data : NSDictionary!
    var cookieData : NSDictionary!
    var assignments = NSArray()
    var cookie : String!
    var id : String!
    var whole : NSArray!
    var color : UIColor!
    var classtitle : String!
    var markingPeriod : String?
    var cours : String!
    var sectio : String!
    var selectedCell : DetailGradeTableViewCell?
    let url = "http://gradecheck.herokuapp.com/"
    @IBOutlet weak var navItem : UINavigationItem!;
    @IBOutlet weak var navBar : UINavigationBar!
    @IBOutlet weak var assignmentTable : UITableView!
    var blurEffectView = UIVisualEffectView()
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      
        if( traitCollection.forceTouchCapability == .Available){
            
            registerForPreviewingWithDelegate(self, sourceView: self.assignmentTable)
            
        }else {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(DetailGradeViewController.handleLongPress))
            self.view.addGestureRecognizer(longPress)
        }
        self.navBar.barTintColor = color;
        self.navItem.title = self.classtitle;
        self.assignmentTable.dataSource = self;
        self.assignmentTable.delegate = self; 
        let cookieArray = self.cookieData.objectForKey("cookie") as? NSArray;
        self.cookie = cookieArray![0] as? String;
        print(self.data)
        self.id = self.cookieData.objectForKey("id") as? String;
        let classString = data.objectForKey("classCodes");
        let secondDemiliter = ":";
        let tok = classString!.componentsSeparatedByString(secondDemiliter);
        let course = tok[0]
        self.cours = course;
        let section = tok[1];
        self.sectio = section
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let cookieString = "cookie=" + self.cookie
        let id : String = NSUserDefaults.standardUserDefaults().objectForKey("id") as! String
        let idString = "&id=" + id
        let courseString = "&course=" + course;
        let sectionString = "&section=" + section;
        let postData = NSMutableData(data: cookieString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(idString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(courseString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(sectionString.dataUsingEncoding(NSUTF8StringEncoding)!)
        if(markingPeriod != nil){
            let mpString = "&mp=" + self.markingPeriod!;
            postData.appendData(mpString.dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        let request = NSMutableURLRequest(URL: NSURL(string: url + "listassignments")!,
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
                                self.assignmentTable.backgroundView = noView;
                            }
                            self.assignmentTable.reloadData()
                            
                        }catch{
                            
                        }
                    })
                    
                }
            }
        })
        
        dataTask.resume()
        

        // Do any additional setup after loading the view.
    }
    func handleLongPress(sender:UILongPressGestureRecognizer){
        if(sender.state == .Began){
            let press = sender.locationInView(self.assignmentTable)
            if let indexPath = self.assignmentTable.indexPathForRowAtPoint(press){
                let cell = self.assignmentTable.cellForRowAtIndexPath(indexPath) as! DetailGradeTableViewCell
                let blurEffect = UIBlurEffect(style: .Light)
                self.blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = self.assignmentTable.bounds;
                blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                self.assignmentTable.addSubview(blurEffectView)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let detailvc = storyboard.instantiateViewControllerWithIdentifier("AssignmentDetail") as! AssignmentDetailModalViewController
                var assignment = NSDictionary()
                assignment = assignments[indexPath.row] as! NSDictionary
                detailvc.calendarReady = cell.calendarReady
                detailvc.assignment = assignment
                detailvc.assignorNo = true;
                self.assignmentTable.deselectRowAtIndexPath(indexPath, animated: true)
                presentViewController(detailvc, animated: true, completion: nil)
            }
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assignments.count;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OverviewCell", forIndexPath: indexPath) as! DetailGradeTableViewCell;
        let object = assignments[indexPath.row];
        cell.assignment = object as! NSDictionary
        let assignDictionary = object.objectForKey("assignment") as! NSDictionary
        cell.assignmentTitle.text = assignDictionary.objectForKey("title") as? String
        cell.detail.text = assignDictionary.objectForKey("details") as? String;
        cell.type.text = object.objectForKey("category") as? String;
        var g = object.objectForKey("percent") as! String;
        cell.grade.grade.text = g
        cell.date.text = object.objectForKey("stringDate") as? String;
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy"
        let dat = dateFormatter.dateFromString(cell.date.text!)
        if((dat) != nil){
            if(dat!.compare(NSDate()) == .OrderedAscending){
                cell.calendarReady = false;
            }else{
                cell.calendarReady = true;
            }
        }else{
            cell.calendarReady = false;
        }
        if(g.containsString("%")){
            g = String(g.characters.dropLast());
            switch Double(g)!{
            case 0..<50:
                cell.grade.backgroundColor = UIColor.blackColor()
                cell.color = UIColor.blackColor()
            case 51..<75 :
                cell.grade.backgroundColor = UIColor.redColor()
                cell.color = UIColor.redColor()
            case 76..<85 :
                cell.grade.backgroundColor = UIColor.yellowColor()
                cell.color = UIColor.yellowColor()
            case 86..<110 :
                cell.grade.backgroundColor = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0);
                cell.color = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0);
            default :
                cell.grade.backgroundColor = UIColor.purpleColor()
                cell.color = UIColor.purpleColor()
            }
        }else{
            cell.grade.backgroundColor = UIColor.blackColor()
            cell.color = UIColor.blackColor()
        }
        cell.backgroundColor = cell.backgroundColor;

        
        return cell;
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let actualCell = cell as! DetailGradeTableViewCell
        actualCell.move()
        actualCell.backgroundColor = actualCell.contentView.backgroundColor;

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func segueBack(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ProjectionSegue", sender: self)
    }
    func ridOfBlur(){
        self.blurEffectView.removeFromSuperview()  
    }
    override func viewDidAppear(animated: Bool) {
        if(self.assignmentTable.indexPathForSelectedRow != nil){
            self.assignmentTable.deselectRowAtIndexPath(self.assignmentTable.indexPathForSelectedRow!, animated: true)
        }
    }
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.assignmentTable.indexPathForRowAtPoint(location) else {return nil}
       
        guard let cell = self.assignmentTable.cellForRowAtIndexPath(indexPath) as? DetailGradeTableViewCell else {return nil}
        self.selectedCell = cell;
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        /*let rectOfCellInTableView: CGRect = self.assignmentTable.rectForRowAtIndexPath(indexPath)
        let rectOfCellInSuperview: CGRect = self.assignmentTable.convertRect(rectOfCellInTableView, toView: self.view)*/
        previewingContext.sourceRect = cell.frame;
        // let detailvc = storyboard.instantiateViewControllerWithIdentifier("AssignmentDetail") as! AssignmentDetailModalViewController
        let detailvc = storyboard.instantiateViewControllerWithIdentifier("ForceTouchAssignment") as! ForceTouchAssignmentsDetailViewController
        var assignment = NSDictionary()
        assignment = assignments[indexPath.row] as! NSDictionary
        detailvc.calendarReady = cell.calendarReady
        detailvc.assignment = assignment
        detailvc.assignorNo = true;
        return detailvc;

    }
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let projectionvc = storyboard.instantiateViewControllerWithIdentifier("ProjectionAssignmentView") as! ProjectionGradeViewController
        var af : DetailGradeTableViewCell!
        if(self.selectedCell != nil){
            af = self.selectedCell
        }
        projectionvc.cookie = self.cookie
        projectionvc.course = self.cours
        projectionvc.section = self.sectio
        projectionvc.assignment = af.assignment
        projectionvc.markingPeriod = self.markingPeriod
        projectionvc.otherAssignments = self.assignments
        projectionvc.color = af.color
        projectionvc.calendarReady = af.calendarReady
        showViewController(projectionvc, sender: self)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "ProjectionSegue"){
            let projectionvc = segue.destinationViewController as! ProjectionGradeViewController
            let selectedIndexPath = self.assignmentTable.indexPathForSelectedRow
            let selectedCell = self.assignmentTable.cellForRowAtIndexPath(selectedIndexPath!) as! DetailGradeTableViewCell
            self.assignmentTable.deselectRowAtIndexPath(selectedIndexPath!, animated: true)
            projectionvc.cookie = self.cookie
            projectionvc.course = self.cours
            projectionvc.section = self.sectio
            projectionvc.assignment = selectedCell.assignment
            projectionvc.markingPeriod = self.markingPeriod
            projectionvc.otherAssignments = self.assignments
            projectionvc.color = selectedCell.color
            projectionvc.calendarReady = selectedCell.calendarReady
        }
        
    }
    

}
