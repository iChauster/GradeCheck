//
//  AssignmentsTableViewCell.swift
//  GradeCheck
//
//  Created by Ivan Chau on 2/24/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit
import EventKit
class AssignmentsTableViewCell: UITableViewCell {
    @IBOutlet weak var title : UILabel!
    @IBOutlet weak var detail : UILabel!
    @IBOutlet weak var grade : GradeView!
    @IBOutlet weak var course : UILabel!
    @IBOutlet weak var date : UILabel!
    @IBOutlet weak var view : UIView!
    @IBOutlet weak var calendarButton : UIButton!
    @IBOutlet weak var parent : AssignmentsTableViewController!
    var dateString : String!
    var calendarReady : Bool = true;
    @IBAction func addtoCalendarClicked(_ sender: AnyObject) {
        if(calendarReady){
            let eventStore = EKEventStore()
            
            eventStore.requestAccess( to: EKEntityType.event, completion:{(granted, error) in
                if (granted) && (error == nil) {
                    var localSource : EKSource = EKSource()
                    for source in eventStore.sources {
                        if (source.sourceType == EKSourceType.calDAV &&
                            source.title == "iCloud")
                        {
                            localSource = source;
                            break;
                        }
                    }
                    
                    if (localSource.title != "iCloud")
                    {
                        for source in eventStore.sources
                        {
                            if (source.sourceType == .local)
                            {
                                localSource = source;
                                break;
                            }
                        }
                    }
                    var calendar : EKCalendar;
                    if (UserDefaults.standard.object(forKey: "calendarIdentifier") == nil || (UserDefaults.standard.object(forKey: "calendarIdentifier") as! String) == ""){
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
                            self.parent.present(failureAlert, animated: true, completion: nil)
                        }
                        UserDefaults.standard.set(calendar.calendarIdentifier, forKey: "calendarIdentifier")
                    }else{
                        if let c = eventStore.calendar(withIdentifier: UserDefaults.standard.object(forKey: "calendarIdentifier") as! String) {
                            calendar = c
                        }else{
                            calendar = eventStore.defaultCalendarForNewEvents!
                        }
                    }
                    print("granted \(granted)")
                    print("error \(error)")
                    let event = EKEvent(eventStore: eventStore)
                    
                    event.title = self.title.text!
                    let dateFormatter = DateFormatter()
                    dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd/yy")
                    let date1 = dateFormatter.date(from: self.dateString);
                    let cal: Calendar! = Calendar(identifier: Calendar.Identifier.gregorian)
                    let startDate = cal.date(bySettingHour: 7, minute: 20, second: 0, of: date1!, matchingPolicy: Calendar.MatchingPolicy.nextTime, repeatedTimePolicy: Calendar.RepeatedTimePolicy.first, direction: Calendar.SearchDirection.forward)
                    
                    event.startDate = startDate!
                    event.endDate = (startDate?.addingTimeInterval(60*60))!;
                    event.notes = self.detail.text!
                    event.calendar = calendar
                    let alarm : EKAlarm = EKAlarm(relativeOffset: -60*60*15)
                    let secondAlarm : EKAlarm = EKAlarm(relativeOffset: -60*60*39)
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
                            let alertString = self.title.text! + " has been added to your calendar! You may need to sync with iCloud calendar to see these features."
                            let alert = UIAlertController(title: "Added to Calendar" , message: alertString, preferredStyle: .alert);
                            let cool = UIAlertAction(title: "Cool!", style: .default, handler: nil)
                            alert.addAction(cool)
                            self.parent.present(alert, animated: true, completion: nil)
                            print("event added !")
                            
                        })
                        
                    }
                }
            })
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.grade.layer.cornerRadius = 0.5 * self.grade.bounds.size.width;
        CellAnimation.growAndShrink(self.grade)
        self.view.layer.cornerRadius = 10;
        // Initialization code
    }
    func move(){
        CellAnimation.growAndShrink(self.grade)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    

}
