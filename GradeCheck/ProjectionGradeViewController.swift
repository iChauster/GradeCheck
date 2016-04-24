//
//  ProjectionGradeViewController.swift
//  GradeCheck
//
//  Created by Ivan Chau on 4/23/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit
import EventKit

class ProjectionGradeViewController: UIViewController {
    @IBOutlet weak var sliderPercentView : SliderPercentView!
    @IBOutlet weak var navBar : UINavigationBar!
    @IBOutlet weak var navItem : UINavigationItem!
    @IBOutlet weak var categoryTitle : UILabel!
    @IBOutlet weak var descriptionTitle : UILabel!
    @IBOutlet weak var maxScore : UILabel!
    @IBOutlet weak var achievedScore : UILabel!
    @IBOutlet weak var newGradeView : AssignmentScoreView!
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var classTitleLabel : UILabel!
    @IBOutlet weak var teacherTitleLabel: UILabel!
    var assignment : NSDictionary!
    var category : String!
    var cookie : String!
    var id : String!
    var course : String!
    var section : String!
    var markingPeriod : String?
    var data : NSArray!
    var otherAssignments : NSArray!
    let url = "http://localhost:2800/"
    var final : NSMutableDictionary! = NSMutableDictionary()
    var weights : NSMutableArray! = NSMutableArray()
    var originalMin : NSDictionary! = NSDictionary()
    var color : UIColor!
    var calendarReady : Bool = true;
    var categoryConversion : Bool = true;
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newGradeView.score.text = ""
        self.id = NSUserDefaults.standardUserDefaults().objectForKey("id") as! String
        self.category = self.assignment["category"] as! String
        self.classTitleLabel.text = self.assignment["course"] as? String
        self.teacherTitleLabel.text = self.assignment["teacher"] as? String
        var image = UIImage()
        self.maxScore.text = self.assignment["gradeMax"] as? String
        if((self.assignment["grade"] as! String) != ""){
            self.achievedScore.text = self.assignment["grade"] as? String
        }else{
            self.achievedScore.text = self.assignment["gradeMax"] as? String;
        }
        self.newGradeView.layer.cornerRadius = self.newGradeView.bounds.height / 2.0;
        if(calendarReady){
            image = UIImage(named:"calendar.png")!
            self.navItem.rightBarButtonItem!.tintColor = UIColor.whiteColor()
            UIGraphicsBeginImageContext(CGSizeMake(30.0, 30.0))
            image.drawInRect(CGRectMake(0, 0, 30.0, 30.0))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.navItem.rightBarButtonItem!.image = newImage.imageWithRenderingMode(.AlwaysTemplate)
        }else{
            image = UIImage(named:"check.png")!.imageWithRenderingMode(.AlwaysOriginal)
            UIGraphicsBeginImageContext(CGSizeMake(30.0, 30.0))
            image.drawInRect(CGRectMake(0, 0, 30.0, 30.0))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.navItem.rightBarButtonItem!.image = newImage.imageWithRenderingMode(.AlwaysOriginal)
        }
        
        self.dateLabel.text = self.assignment["stringDate"] as? String
        if(self.assignment["assignment"]!["details"] != nil && (self.assignment["assignment"]!["details"] as? String) != ""){
            self.descriptionTitle.text = self.assignment["assignment"]!["details"] as? String
        }else{
            self.descriptionTitle.text = "No Description"
        }
        self.categoryTitle.text = self.category
        print(self.color)
        self.navBar.barTintColor = self.color
        self.navItem.title = self.assignment["assignment"]!["title"] as? String
        self.navBar.tintColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
        self.sliderPercentView.layer.cornerRadius = self.sliderPercentView.bounds.height/2.0
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let cookieString = "cookie=" + self.cookie
        let id : String = NSUserDefaults.standardUserDefaults().objectForKey("id") as! String
        let idString = "&id=" + id
        let courseString = "&courseCode=" + course;
        let sectionString = "&courseSection=" + section;
        let postData = NSMutableData(data: cookieString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(idString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(courseString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(sectionString.dataUsingEncoding(NSUTF8StringEncoding)!)
        if(markingPeriod != nil){
            let mpString = "&mp=" + self.markingPeriod!;
            postData.appendData(mpString.dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        let request = NSMutableURLRequest(URL: NSURL(string: url + "getClassWeighting")!,
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
                            self.data = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray;
                            if((self.data[0] as! String) == "Total Points"){
                                print("Total point conversion");
                                self.categoryConversion = false
                            }else if((self.data[0] as! String) == "Category Weighting"){
                                let arr = self.data[1] as! NSArray
                                for obj in arr {
                                    let dict = obj as! NSDictionary
                                    self.categoryConversion = true
                                    self.weights.addObject(dict)
                                }
                            }
                            self.sum()
                            self.adjustMin()
                        }catch{
                            
                        }
                    })
                    
                }
            }
        })
        
        dataTask.resume()
        

    }
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    func sum(){
        let assignmentTitle = assignment["assignment"]!["title"] as! String
        for obj in otherAssignments{
            let dict = obj as! NSDictionary
            print(dict)
            let key = dict["category"] as! String
            if((dict["assignment"]!["title"] as! String) == assignmentTitle){
                if let val = final[key]{
                    print(val)
                }else{
                    let array = NSMutableArray();
                    array[0] = 0
                    array[1] = 0
                    final.setValue(array, forKey:(dict["category"] as! String))
                }
            }else{
                if dict["grade"] != nil && (dict["grade"]as! String) != "" {
                    if let val = final[key]{
                        let array = val as! NSMutableArray
                        var min = array[0] as! Double
                        var max = array[1] as! Double
                        min += Double(dict["grade"] as! String)!
                        max += Double(dict["gradeMax"] as! String)!
                        array[0] = min;
                        array[1] = max;
                    }else{
                        let array = NSMutableArray()
                        let minString = dict["grade"] as! String
                        let maxString = dict["gradeMax"] as! String
                        array[0] = Double(minString)!
                        array[1] = Double(maxString)!
                        final.setValue(array, forKey: (dict["category"]as! String))
                    }
                }
            }
        }
        self.originalMin = final.copy() as! NSDictionary;
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func closeView(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func adjustMin(){
        print(originalMin)
        let minimumScore = self.sliderPercentView.currentValue * 0.01 * Double(self.maxScore.text!)!
        self.achievedScore.text = String(format:"%.2f",minimumScore)
        let minDoubs = self.originalMin[self.category]![0] as! Double
        let newMin = minDoubs + minimumScore
        let maxDoubs = self.originalMin[self.category]![1] as! Double
        let newMax = maxDoubs + Double(self.assignment["gradeMax"] as! String)!
        let array = [newMin, newMax]
        self.final[self.category] = array
        self.findFinalGrade()
    }
    func findFinalGrade(){
        if(categoryConversion == true){
            var finalGrade = 0.0;
            var totalWeights = 0.0;
            for obj in self.weights{
                let dict = obj as! NSDictionary
                for (kind,weights) in dict {
                    if(kind as! String == "category"){
                        print(final)
                        if let array = final[weights as! String] as? NSArray{
                        let percentage = (array[0] as! Double) / (array[1] as! Double)
                        print("should multiply "  + String(percentage) + "with" + (dict["weight"]as! String))
                        let pe = String((dict["weight"] as! String).characters.dropLast().dropLast())
                        totalWeights += Double(pe)!
                        print(pe)
                        finalGrade += Double(pe)! * 0.01 * percentage
                        }
                    }
                }
            }
            print(totalWeights)
            finalGrade *= 100.0
            finalGrade /= totalWeights
            finalGrade *= 100.0
            self.newGradeView.score.text = String(format: "%.2f", finalGrade) + "%"
            switch(Int(finalGrade)){
            case 0..<50:
                self.newGradeView.backgroundColor = UIColor.blackColor()
            case 50..<75 :
                self.newGradeView.backgroundColor = UIColor.redColor()
            case 75..<85 :
                self.newGradeView.backgroundColor = UIColor.yellowColor()
            case 85..<110 :
                self.newGradeView.backgroundColor = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0)
            default :
                self.newGradeView.backgroundColor = UIColor.blackColor()

            }
        }else{
            print(final)
            var gradeMax = 0.0
            var gradeAchieved = 0.0
            for (_,values) in final {
                gradeAchieved += values[0] as! Double
                gradeMax += values[1] as! Double
            }
            let percentage = gradeAchieved / gradeMax * 100
            self.newGradeView.score.text = String(format: "%.2f",percentage)
            switch(Int(percentage)){
            case 0..<50:
                self.newGradeView.backgroundColor = UIColor.blackColor()
            case 50..<75 :
                self.newGradeView.backgroundColor = UIColor.redColor()
            case 75..<85 :
                self.newGradeView.backgroundColor = UIColor.yellowColor()
            case 85..<110 :
                self.newGradeView.backgroundColor = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0)
            default :
                self.newGradeView.backgroundColor = UIColor.blackColor()
                
            }

        }
    }
    @IBAction func addtoCalendarClicked(sender: AnyObject) {
        if(calendarReady){
            let eventStore = EKEventStore()
            
            eventStore.requestAccessToEntityType( EKEntityType.Event, completion:{(granted, error) in
                
                if (granted) && (error == nil) {
                    print("granted \(granted)")
                    print("error \(error)")
                    
                    let event = EKEvent(eventStore: eventStore)
                    
                    event.title = self.navItem.title!
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd/yy")
                    let date1 = dateFormatter.dateFromString(self.dateLabel.text!);
                    
                    
                    event.startDate = date1!
                    event.endDate = (date1?.dateByAddingTimeInterval(60*60))!;
                    event.notes = self.descriptionTitle.text!
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    let alarm : EKAlarm = EKAlarm(relativeOffset: -60*60*24)
                    event.alarms = [alarm]
                    var event_id = ""
                    do{
                        try eventStore.saveEvent(event, span: .ThisEvent)
                        event_id = event.eventIdentifier
                    }
                    catch let error as NSError {
                        print("json error: \(error.localizedDescription)")
                    }
                    
                    if(event_id != ""){
                        dispatch_async(dispatch_get_main_queue(), {
                            let alertString = self.navItem.title! + " has been added to your calendar!"
                            let alert = UIAlertController(title: "Added to Calendar" , message: alertString, preferredStyle: .Alert);
                            let cool = UIAlertAction(title: "Cool!", style: .Default, handler: nil)
                            alert.addAction(cool)
                            self.presentViewController(alert, animated: true, completion: nil)
                            print("event added !")
                            
                        })
                        
                    }
                }
            })
        }
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
