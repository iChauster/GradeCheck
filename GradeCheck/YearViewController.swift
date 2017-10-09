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
        year.text = yearString;
        v.layer.cornerRadius = 20
        GPAView.clipsToBounds = true
        GPAView.layer.cornerRadius = GPAView.frame.width / 2;
        GPAView.layer.borderWidth = 2
        GPAView.layer.borderColor = UIColor().ICGreen.cgColor
        
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
        var obj = data[indexPath.row] as! Dictionary<String, Int>
        cell.classg.text = element.object(forKey: "class") as? String;
        cell.grade.text = element.object(forKey: "grade") as? String;
        cell.teacher.text = element.object(forKey: "teacher") as? String;
        var g = element.object(forKey: "grade") as! String;
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
        cell.backgroundColor = cell.backgroundColor;
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0.3647, green: 0.8431, blue: 0.3176, alpha: 1.0);
        backgroundView.alpha = 0.0;
        cell.selectedBackgroundView = backgroundView
        return cell
        return UITableViewCell()
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
