//
//  DetailGradeViewController.swift
//  GradeCheck
//
//  Created by Ivan Chau on 3/23/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class DetailGradeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var data : NSDictionary!
    var cookieData : NSDictionary!
    var assignments = NSArray()
    var cookie : String!
    var id : String!
    var whole : NSArray!
    var color : UIColor!
    var classtitle : String!
    let url = "https://gradecheck.herokuapp.com/"
    @IBOutlet weak var navItem : UINavigationItem!;
    @IBOutlet weak var navBar : UINavigationBar!
    @IBOutlet weak var assignmentTable : UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navBar.barTintColor = color;
        self.navItem.title = self.classtitle;
        self.assignmentTable.dataSource = self;
        self.assignmentTable.delegate = self;
        let cookieArray = self.cookieData.objectForKey("cookie") as? NSArray;
        self.cookie = cookieArray![0] as? String;
        self.id = self.cookieData.objectForKey("id") as? String;
        let delimiter = " -"
        let classString = data.objectForKey("class");
        let token = classString?.componentsSeparatedByString(delimiter)
        let final =  token![0];
        print(final);
        let secondDemiliter = "/";
        let tok = final.componentsSeparatedByString(secondDemiliter);
        let course = tok[0]
        let section = tok[1];
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
                            self.assignments = self.assignments.reverse()
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
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assignments.count;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OverviewCell", forIndexPath: indexPath) as! DetailGradeTableViewCell;
        let object = assignments[indexPath.row];
        
        let assignDictionary = object.objectForKey("assignment") as! NSDictionary
        cell.assignmentTitle.text = assignDictionary.objectForKey("title") as? String
        cell.detail.text = assignDictionary.objectForKey("details") as? String;
        cell.type.text = object.objectForKey("category") as? String;
        var g = object.objectForKey("percent") as! String;
        cell.grade.grade.text = g
        cell.date.text = object.objectForKey("stringDate") as? String;
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

        
        return cell;
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let actualCell = cell as! DetailGradeTableViewCell
        actualCell.move()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func segueBack(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    

}
