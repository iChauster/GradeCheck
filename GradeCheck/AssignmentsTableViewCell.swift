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
    @IBOutlet weak var parent : AssignmentsTableViewController!
    var dateString : String!

    @IBAction func addtoCalendarClicked(sender: AnyObject) {
        
        let eventStore = EKEventStore()
        
        eventStore.requestAccessToEntityType( EKEntityType.Event, completion:{(granted, error) in
            
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(error)")
                
                let event = EKEvent(eventStore: eventStore)
                
                event.title = self.title.text!
                let dateFormatter = NSDateFormatter()
                dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd/yy")
                let date1 = dateFormatter.dateFromString(self.dateString);
                
           
                event.startDate = date1!
                event.endDate = (date1?.dateByAddingTimeInterval(60*60))!;
                event.notes = self.detail.text!
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
                        let alertString = self.title.text! + " has been added to your calendar!"
                        let alert = UIAlertController(title: "Added to Calendar" , message: alertString, preferredStyle: .Alert);
                        let cool = UIAlertAction(title: "Cool!", style: .Default, handler: nil)
                        alert.addAction(cool)
                        self.parent.presentViewController(alert, animated: true, completion: nil)
                        print("event added !")

                    })

                }
            }
        })
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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
