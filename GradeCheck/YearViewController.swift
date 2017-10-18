//
//  YearViewController.swift
//  GradeCheck
//
//  Created by Ivan Chau on 10/5/17.
//  Copyright © 2017 Ivan Chau. All rights reserved.
//

import UIKit

class YearViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var v : UIView!
    @IBOutlet weak var year : UILabel!
    @IBOutlet weak var GPAView : UIView!
    @IBOutlet weak var GPA : UILabel!
    @IBOutlet weak var numericalGPA : UILabel!
    @IBOutlet weak var tabe : UITableView!
    var data : Array! = []
    var yearString : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        print(data)
        year.text = "Grade " + yearString;
        v.layer.cornerRadius = 20
        GPAView.clipsToBounds = true
        GPAView.layer.cornerRadius = GPAView.frame.width / 2;
        GPAView.layer.borderWidth = 2
        GPAView.layer.borderColor = UIColor().ICGreen.cgColor
        tabe.rowHeight = 80;
        tabe.estimatedRowHeight = 80;
        let gpahistory = self.parent as! GPAHistoryViewController
        let gestureRecog = UISwipeGestureRecognizer(target: gpahistory , action: Selector("dismissController"))
        gestureRecog.direction = .up
        self.view.addGestureRecognizer(gestureRecog)
        getGPA()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GPAViewCell", for: indexPath) as! GPAViewCell;

        var obj = data[indexPath.row] as! Dictionary<String, String>
        cell.classg.text = obj["class"]
        cell.grade.text = obj["grade"]! + "%"
        var g = obj["grade"]! + "%"
        if(g.contains("%")){
            g = String(g.characters.dropLast());
            let color = UIColor().getColor(grade: Double(g)!)
            cell.views.backgroundColor = color
            cell.color = color
            cell.percent = Int(g)
        }else{
            cell.views.backgroundColor = UIColor.black
            cell.color = UIColor.black
            cell.percent = -1;
        }
        cell.backgroundColor = cell.backgroundColor
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0.3647, green: 0.8431, blue: 0.3176, alpha: 1.0);
        backgroundView.alpha = 0.0;
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    func getGPA(){
        var gradeTotal = 0.0;
        var classes = 0;
        var gpaTotal = 0.0;
        for i in 0 ..< data.count{
            
            let a = data[i] as! Dictionary<String, String>
            print(a)
            print(a["grade"])
            print(a["class"])
            var grade : String!;
            var gradeInt : Int!;
            
        
            if(a["grade"] == "No Grades" || a["grade"] == "0%"){
                continue;
            }
            if((((a["class"]?.contains(" H"))! && a["class"]?.characters.last == "H") || (a["class"]?.contains("AP"))! || (a["class"]?.contains("Honors"))! || (a["class"]?.contains("Hon"))!) && UserDefaults.standard.object(forKey: "GPA") as! String == "Weighted"){
                grade = a["grade"]
                gradeInt = Int(grade)! + 5;
                gradeTotal += Double(gradeInt);

                if(gradeInt > 100){
                    gradeInt = 100;
                }
                gpaTotal += Double(gradeInt);
                classes += 1;
                
            }else{
                grade = a["grade"]
                gradeInt = Int(grade)!;
                gradeTotal += Double(gradeInt);
                if(gradeInt > 95){
                    gradeInt = 95;
                }
                gpaTotal += Double(gradeInt);
                classes += 1;
            }
            
        }
        
        var average = gradeTotal/Double(classes);
        average = round(average*100.0)/100.0;
        let gpaAvg = gpaTotal/Double(classes);
        print(gpaAvg);
        print(round(gpaAvg))
        let gpaDifference = 10 - round(gpaAvg)/10
        print(gpaDifference);
        let gpa = 4.5 - gpaDifference;
        print(gpa);
        self.GPA.text = String(gpa)
        self.numericalGPA.text = String(average) + "%";
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
