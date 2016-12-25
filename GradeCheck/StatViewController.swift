//
//  StatViewController.swift
//  GradeCheck
//
//  Created by Ivan Chau on 3/12/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class Grade : NSObject {
    var grade : Int!
    var classTitle : String!
    var dictionaryObject : NSDictionary!
    init(grade:Int, className:String, dictionaryObject : NSDictionary){
        self.grade = grade;
        self.classTitle = className;
        self.dictionaryObject = dictionaryObject;
    }
}

class StatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var gpaCircle : GPAView!
    @IBOutlet weak var statTable : UITableView!
    @IBOutlet weak var settings : UIButton!
    var gradesArray = NSArray();
    var sortedArray : [Grade] = [];
    var cookie : String!
    var idString : String!
    @IBAction func settingsSelected(_ sender:UIButton){
        CellAnimation.growAndShrink(self.settings)
        self.performSegue(withIdentifier: "SettingSegue", sender: self)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gpaCircle.layer.cornerRadius = 0.5 * gpaCircle.bounds.size.width;
        self.statTable.dataSource = self;
        self.statTable.delegate = self;
        self.statTable.layer.cornerRadius = 10;
        let leftSwipe = UISwipeGestureRecognizer(target: self.tabBarController, action: #selector(GradeViewController.swipeLeft))
        leftSwipe.direction = .left
        self.view.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self.tabBarController, action: #selector(GradeViewController.swipeRight))
        rightSwipe.direction = .right;
        self.view.addGestureRecognizer(rightSwipe)

        
        self.getGPA()
        // Do any additional setup after loading the view.
    }
    func touched(){
        print("called")
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatClassCell", for: indexPath) as! StatTableViewCell;
        let element = self.sortedArray[indexPath.row] ;
        cell.classTitle.text = element.classTitle
        let g = element.grade
            switch Int(g!){
            case 0..<50:
                cell.backgroundColor = UIColor.black
            case 51..<75 :
                cell.backgroundColor = UIColor.red
            case 76..<85 :
                cell.backgroundColor = UIColor.yellow
            case 86..<110 :
                cell.backgroundColor = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0);
            default :
                cell.backgroundColor = UIColor.purple
            }
       
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedArray.count;
    }
    override func viewDidAppear(_ animated: Bool) {
        self.getGPA()
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let realCell = cell as! StatTableViewCell;
        realCell.backgroundColor = realCell.backgroundColor;
        CellAnimation.slide(realCell)
    }
    func getGPA(){
        var gradeTotal = 0.0;
        var classes = 0;
        var gpaTotal = 0.0;
        self.sortedArray = [];
        for i in 0 ..< gradesArray.count{
            if(i == 0){
                continue;
            }
            
            let a = gradesArray[i];
            var grade : String!;
            var gradeInt : Int!;
            
            if((a as AnyObject).object(forKey: "grade") as! String == "No Grades" || (a as AnyObject).object(forKey: "grade") as! String == "0%"){
                let new = Grade(grade: 0, className: (gradesArray[i] as AnyObject).object(forKey: "class") as! String, dictionaryObject : a as! NSDictionary);
                self.sortedArray.append(new)
                continue;
            }
            if(((((a as AnyObject).object(forKey: "class")! as AnyObject).contains(" H") && ((a as AnyObject).object(forKey: "class") as! String).characters.last == "H") || ((a as AnyObject).object(forKey: "class")! as AnyObject).contains("AP") || ((a as AnyObject).object(forKey: "class")! as AnyObject).contains("Honors") || ((a as AnyObject).object(forKey: "class")! as AnyObject).contains("Hon")) && UserDefaults.standard.object(forKey: "GPA") as! String == "Weighted"){
                grade = (a as AnyObject).object(forKey: "grade") as! String;
                grade = String(grade.characters.dropLast());
                gradeInt = Int(grade)! + 5;
                gradeTotal += Double(gradeInt);
                let new = Grade(grade: gradeInt, className: (a as AnyObject).object(forKey: "class") as! String, dictionaryObject : a as! NSDictionary);
                self.sortedArray.append(new);
                if(gradeInt > 100){
                    gradeInt = 100;
                }
                gpaTotal += Double(gradeInt);
                classes += 1;
                
            }else{
                grade = (a as AnyObject).object(forKey: "grade") as! String
                grade = String(grade.characters.dropLast());
                gradeInt = Int(grade)!;
                let new = Grade(grade: gradeInt, className: (a as AnyObject).object(forKey: "class") as! String, dictionaryObject : a as! NSDictionary);
                self.sortedArray.append(new);
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
        CellAnimation.growAndShrink(self.gpaCircle);
        self.gpaCircle.GPA.text = String(gpa)
        self.gpaCircle.avg.text = String(average) + "%";
        self.sortedArray.sort { (element, second) -> Bool in
            return element.grade > second.grade
        }
        self.statTable.reloadData()

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "StatSegue", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "StatSegue"){
            let view = segue.destination as! DetailStatViewController
            view.data = self.sortedArray[self.statTable.indexPathForSelectedRow!.row].dictionaryObject as NSDictionary
            view.gradesArray = self.gradesArray
            view.cookie = self.cookie;
            let selectedObject = self.sortedArray[self.statTable.indexPathForSelectedRow!.row];
            view.className = selectedObject.classTitle
            self.statTable.deselectRow(at: self.statTable.indexPathForSelectedRow!, animated: true)
            if(UserDefaults.standard.object(forKey: "GradeTableMP") != nil && (UserDefaults.standard.object(forKey: "GradeTableMP") as! String) != "MP4"){
                view.markingPeriod = UserDefaults.standard.object(forKey: "GradeTableMP") as? String
            }

        }else if(segue.identifier == "SettingSegue"){
            let view = segue.destination as! SettingsViewController
            view.objectID = self.idString
        }
    }
    

}
