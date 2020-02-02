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
    @IBOutlet weak var xView : UIView!
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
    //let url = "http://gradecheck.herokuapp.com/"
    var final : NSMutableDictionary! = NSMutableDictionary()
    var weights : NSMutableArray! = NSMutableArray()
    var originalMin : NSDictionary! = NSDictionary()
    var color : UIColor!
    var calendarReady : Bool = true;
    var categoryConversion : Bool = true;

    override func viewDidLoad() {
        super.viewDidLoad()
        self.newGradeView.score.text = ""
        self.id = UserDefaults.standard.object(forKey: "id") as! String
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
            self.navItem.rightBarButtonItem!.tintColor = UIColor.white
            UIGraphicsBeginImageContext(CGSize(width: 30.0, height: 30.0))
            image.draw(in: CGRect(x: 0, y: 0, width: 30.0, height: 30.0))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.navItem.rightBarButtonItem!.image = newImage?.withRenderingMode(.alwaysTemplate)
        }else{
            image = UIImage(named:"check.png")!.withRenderingMode(.alwaysOriginal)
            UIGraphicsBeginImageContext(CGSize(width: 30.0, height: 30.0))
            image.draw(in: CGRect(x: 0, y: 0, width: 30.0, height: 30.0))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.navItem.rightBarButtonItem!.image = newImage?.withRenderingMode(.alwaysOriginal)
        }
        
        self.dateLabel.text = self.assignment["stringDate"] as? String
        let dict = self.assignment["assignment"]! as! NSDictionary
        if(dict["details"] != nil && (dict["details"] as? String) != ""){
            self.descriptionTitle.text = dict["details"] as? String
        }else{
            self.descriptionTitle.text = "No Description"
        }
        self.categoryTitle.text = self.category
        print(self.color)
        self.navBar.barTintColor = self.color
        self.xView.backgroundColor = self.color
        self.navItem.title = dict["title"] as? String
        self.navBar.tintColor = UIColor.white
        // Do any additional setup after loading the view.
        self.sliderPercentView.layer.cornerRadius = self.sliderPercentView.bounds.height/2.0
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let cookieString = "cookie=" + self.cookie
        let id : String = UserDefaults.standard.object(forKey: "id") as! String
        let idString = "&id=" + id
        let courseString = "&courseCode=" + course;
        let sectionString = "&courseSection=" + section;
        var postData = NSData(data: cookieString.data(using: String.Encoding.utf8)!) as Data
        postData.append(idString.data(using: String.Encoding.utf8)!)
        postData.append(courseString.data(using: String.Encoding.utf8)!)
        postData.append(sectionString.data(using: String.Encoding.utf8)!)
        if(markingPeriod != nil){
            let mpString = "&mp=" + self.markingPeriod!;
            postData.append(mpString.data(using: String.Encoding.utf8)!)
        }
        let request = NSMutableURLRequest(url: URL(string: url + "getClassWeighting")!,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error ?? "Darn")
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? "Darn")
                if(httpResponse?.statusCode == 200){
                    DispatchQueue.main.async(execute: {
                        do{
                            self.data = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray;
                            if((self.data[0] as! String) == "Total Points"){
                                print("Total point conversion");
                                self.categoryConversion = false
                            }else if((self.data[0] as! String) == "Category Weighting"){
                                let arr = self.data[1] as! NSArray
                                self.categoryConversion = true
                                for obj in arr {
                                    let dict = obj as! NSDictionary
                                    self.weights.add(dict)
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
    override var prefersStatusBarHidden : Bool {
        return true;
    }
    func sum(){
        let dict = assignment["assignment"]! as! NSDictionary
        let assignmentTitle = dict["title"] as! String
        for obj in otherAssignments{
            let dict = obj as! NSDictionary
            let key = dict["category"] as! String
            let d = dict["assignment"]! as! NSDictionary
            if((d["title"] as! String) == assignmentTitle){
                if let val = final[key]{
                    print(val)
                }else{
                    let array = NSMutableArray();
                    array[0] = 0.0
                    array[1] = 0.0
                    final.setValue(array, forKey:(dict["category"] as! String))
                }
            }else{
                if dict["grade"] != nil && (dict["grade"]as! String) != "" {
                    if let val = final[key]{
                        let array = val as! NSMutableArray
                        var min = array[0] as! Double
                        var max = array[1] as! Double
                        print(dict)
                        if let dou = Double(dict["grade"] as! String){
                            min += dou
                            max += Double(dict["gradeMax"] as! String)!
                            array[0] = min;
                            array[1] = max;
                        }else{
                            
                        }
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
        self.dismiss(animated: true, completion: nil)
    }
    func adjustMin(){
        if let b = self.maxScore.text {
            if let a = Double(b) {
            let minimumScore = self.sliderPercentView.currentValue * 0.01 * a
            self.achievedScore.text = String(format:"%.2f",minimumScore)
            print(self.originalMin[self.category]!)
            var arr = self.originalMin[self.category] as! [Double]
            let minDoubs = arr[0]
            let newMin = minDoubs + minimumScore
            let maxDoubs = arr[1]
            let newMax = maxDoubs + Double(self.assignment["gradeMax"] as! String)!
            let array = [newMin, newMax]
            self.final[self.category] = array
            self.findFinalGrade()
            }else{
                let alert = UIAlertController(title: "Grade Error", message: "Grade cannot be read.", preferredStyle: .alert)
                let action = UIAlertAction(title: "Aw.", style: .default, handler: { (alert : UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            let alert = UIAlertController(title: "Grade Error", message: "Grade cannot be read.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Aw.", style: .default, handler: { (alert : UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
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
                if(!(self.newGradeView.backgroundColor!.isEqual(UIColor.black))){
                    UIView.animate(withDuration: 1.0, animations: {
                        self.newGradeView.backgroundColor = UIColor.black
                        self.newGradeView.score.textColor = UIColor.white
                    })
                }
            case 50..<75 :
                if(!(self.newGradeView.backgroundColor!.isEqual(UIColor.red))){
                    UIView.animate(withDuration: 1.0, animations: {
                        self.newGradeView.backgroundColor = UIColor.red
                        self.newGradeView.score.textColor = UIColor.white
                    })
                }
            case 75..<85 :
                if(!(self.newGradeView.backgroundColor!.isEqual(UIColor().ICYellow))){
                    UIView.animate(withDuration: 1.0, animations: {
                        self.newGradeView.backgroundColor = UIColor().ICYellow
                        self.newGradeView.score.textColor = UIColor.black
                    })
                }
            case 85..<110 :
                if(!(self.newGradeView.backgroundColor!.isEqual(UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0)))){
                    UIView.animate(withDuration: 1.0, animations: {
                        self.newGradeView.backgroundColor = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0)
                        self.newGradeView.score.textColor = UIColor.white
                    })
                }
            default :
                if(!(self.newGradeView.backgroundColor!.isEqual(UIColor.black))){
                    UIView.animate(withDuration: 1.0, animations: {
                        self.newGradeView.backgroundColor = UIColor.black
                        self.newGradeView.score.textColor = UIColor.white
                    })
                }
            }
        }else{
            print(final)
            var gradeMax = 0.0
            var gradeAchieved = 0.0
            for (_,values) in final {
                let arr : [Double] = values as! [Double]
                gradeAchieved += arr[0]
                gradeMax += arr[1]
            }
            let percentage = gradeAchieved / gradeMax * 100
            self.newGradeView.score.text = String(format: "%.2f",percentage) + "%"
            switch(Int(percentage)){
            case 0..<50:
                if(!(self.newGradeView.backgroundColor!.isEqual(UIColor.black))){
                    UIView.animate(withDuration: 1.0, animations: {
                        self.newGradeView.backgroundColor = UIColor.black
                        self.newGradeView.score.textColor = UIColor.white
                    })
                }
            case 50..<75 :
                if(!(self.newGradeView.backgroundColor!.isEqual(UIColor.red))){
                    UIView.animate(withDuration: 1.0, animations: {
                        self.newGradeView.backgroundColor = UIColor.red
                        self.newGradeView.score.textColor = UIColor.white
                    })
                }
            case 75..<85 :
                if(!(self.newGradeView.backgroundColor!.isEqual(UIColor().ICYellow))){
                    UIView.animate(withDuration: 1.0, animations: {
                        self.newGradeView.backgroundColor = UIColor().ICYellow
                        self.newGradeView.score.textColor = UIColor.black
                    })
                }
            case 85..<110 :
                if(!(self.newGradeView.backgroundColor!.isEqual(UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0)))){
                    UIView.animate(withDuration: 1.0, animations: {
                        self.newGradeView.backgroundColor = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0)
                        self.newGradeView.score.textColor = UIColor.white
                    })
                }
            default :
                if(!(self.newGradeView.backgroundColor!.isEqual(UIColor.black))){
                    UIView.animate(withDuration: 1.0, animations: {
                        self.newGradeView.backgroundColor = UIColor.black
                        self.newGradeView.score.textColor = UIColor.white
                    })
                }
            }

        }
    }
    @IBAction func addtoCalendarClicked(_ sender: AnyObject) {
        if(calendarReady){
            let eventStore = EKEventStore()
            
            eventStore.requestAccess( to: EKEntityType.event, completion:{(granted, error) in
                
                if (granted) && (error == nil) {
                    print("granted \(granted)")
                    print("error \(error)")
                    
                    let event = EKEvent(eventStore: eventStore)
                    var localSource : EKSource = EKSource()
                    for source in eventStore.sources {
                        if (source.sourceType == .local){
                            localSource = source
                            break;
                        }
                    }
                    var calendar : EKCalendar
                    if (UserDefaults.standard.object(forKey: "calendarIdentifier") == nil){
                        calendar = EKCalendar(for: EKEntityType.event, eventStore: eventStore)
                        calendar.title = "GradeCheck"
                        calendar.cgColor = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0).cgColor
                        calendar.source = localSource
                        do{
                            try eventStore.saveCalendar(calendar, commit: true)
                        }catch let error as NSError{
                            let failureAlert = UIAlertController(title: "Error", message: "Failed to create calendar." + error.localizedDescription, preferredStyle: .alert)
                            let action = UIAlertAction(title: "Darn.", style: .default, handler: nil)
                            failureAlert.addAction(action)
                            self.present(failureAlert, animated: true, completion: nil)
                        }
                        UserDefaults.standard.set(calendar.calendarIdentifier, forKey: "calendarIdentifier")
                    }else{
                        calendar = eventStore.calendar(withIdentifier: UserDefaults.standard.object(forKey: "calendarIdentifier") as! String)!
                    }

                    event.title = self.navItem.title!
                    let dateFormatter = DateFormatter()
                    dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd/yy")
                    let date1 = dateFormatter.date(from: self.dateLabel.text!);
                    let cal: Calendar! = Calendar(identifier: Calendar.Identifier.gregorian)
                    let startDate = cal.date(bySettingHour: 7, minute: 20, second: 0, of: date1!, matchingPolicy: Calendar.MatchingPolicy.nextTime, repeatedTimePolicy: Calendar.RepeatedTimePolicy.first, direction: Calendar.SearchDirection.forward)
                    
                    event.startDate = startDate!
                    event.endDate = (startDate?.addingTimeInterval(60*60))!;
                    event.calendar = calendar
                    let alarm : EKAlarm = EKAlarm(relativeOffset: -60*60*15)
                    let secondAlarm : EKAlarm = EKAlarm(relativeOffset: -60*60*39)
                    event.notes = self.descriptionTitle.text!
                    event.alarms = [alarm, secondAlarm]
                    var event_id = ""
                    do{
                        try eventStore.save(event, span: .thisEvent)
                        event_id = event.eventIdentifier
                    }
                    catch let error as NSError {
                        print("json error: \(error.localizedDescription)")
                    }
                    
                    if(event_id != ""){
                        DispatchQueue.main.async(execute: {
                            let alertString = self.navItem.title! + " has been added to your calendar!"
                            let alert = UIAlertController(title: "Added to Calendar" , message: alertString, preferredStyle: .alert);
                            let cool = UIAlertAction(title: "Cool!", style: .default, handler: nil)
                            alert.addAction(cool)
                            self.present(alert, animated: true, completion: nil)
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
