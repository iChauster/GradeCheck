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
    var classGrade : String?
    var classTeacher : String?
    var cours : String!
    var sectio : String!
    var selectedCell : DetailGradeTableViewCell?
    var gradeFrame : CGRect!
    let url = "http://gradecheck.herokuapp.com/"
    //let url = "http://localhost:2800/"

    @IBOutlet weak var navItem : UINavigationItem!;
    @IBOutlet weak var navBar : UINavigationBar!
    @IBOutlet weak var assignmentTable : UITableView!
    @IBOutlet weak var slideCell : SlideCell!
    var blurEffectView = UIVisualEffectView()
    
    override var prefersStatusBarHidden : Bool {
        return true;
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      
        if( traitCollection.forceTouchCapability == .available){
            
            registerForPreviewing(with: self, sourceView: self.assignmentTable)
            
        }else {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(DetailGradeViewController.handleLongPress))
            self.view.addGestureRecognizer(longPress)
        }
        self.navBar.alpha = 0.0;
        self.assignmentTable.alpha = 0.0;
        Bundle.main.loadNibNamed("detailCell", owner: self, options: nil)
        slideCell.autoresizingMask = [.flexibleWidth ,
            .flexibleLeftMargin , .flexibleRightMargin ,
            ]
        self.view.addSubview(slideCell)
        slideCell.frame = gradeFrame
        self.slideCell.content.backgroundColor = self.color
        self.navBar.barTintColor = color;
        self.navItem.title = self.classtitle;
        self.slideCell.course.text = self.classtitle
        self.slideCell.grade.text = self.classGrade
        self.slideCell.teacher.text = self.classTeacher
        self.assignmentTable.dataSource = self;
        self.assignmentTable.delegate = self; 
        let cookieArray = self.cookieData.object(forKey: "cookie") as? NSArray;
        self.cookie = cookieArray![0] as? String;
        print(self.data)
        self.id = self.cookieData.object(forKey: "id") as? String;
        let classString = data.object(forKey: "classCodes");
        let secondDemiliter = ":";
        let tok = (classString! as AnyObject).components(separatedBy: secondDemiliter);
        let course = tok[0]
        self.cours = course;
        let section = tok[1];
        self.sectio = section
        self.getClassInformation(course: course, section: section)
    
        // Do any additional setup after loading the view.
    }
    func getClassInformation(course:String, section: String){
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let cookieString = "cookie=" + self.cookie
        let id : String = UserDefaults.standard.object(forKey: "id") as! String
        let idString = "&id=" + id
        let courseString = "&course=" + course;
        let sectionString = "&section=" + section;
        var postData = NSData(data: cookieString.data(using: String.Encoding.utf8)!) as Data
        postData.append(idString.data(using: String.Encoding.utf8)!)
        postData.append(courseString.data(using: String.Encoding.utf8)!)
        postData.append(sectionString.data(using: String.Encoding.utf8)!)
        if(markingPeriod != nil){
            let mpString = "&mp=" + self.markingPeriod!;
            postData.append(mpString.data(using: String.Encoding.utf8)!)
        }
        let request = NSMutableURLRequest(url: URL(string: url + "listassignments")!,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
                if(httpResponse?.statusCode == 200){
                    DispatchQueue.main.async(execute: {
                        do{
                            self.assignments = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray;
                            if(self.assignments.count == 0){
                                print("No Assignments")
                                let noView = UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height))
                                //noView.backgroundColor = UIColor(red: 0.0, green: 0.5019, blue: 0.2509, alpha: 1.0)
                                let noLabel = UILabel(frame:CGRect(x: 10,y: 0, width: 240,height: 21));
                                noLabel.textAlignment = .center;
                                noLabel.text = "No Assignments :)";
                                noLabel.textColor = UIColor.white
                                noLabel.center = self.view.convert(self.view.center, to: self.assignmentTable)
                                //noLabel.center.y -= 42 + 44
                                noView.addSubview(noLabel)
                                noView.bringSubview(toFront: noLabel)
                                self.assignmentTable.backgroundView = noView;
                            }
                            UIView.animate(withDuration: 0.8, delay: 0.0, options: [.allowAnimatedContent,.curveEaseInOut,], animations: {
                                //self.slideCell.frame.origin.y = 0
                                self.slideCell.frame.origin.y = self.assignmentTable.frame.origin.y - 86
                                self.assignmentTable.alpha = 1;
                            }, completion: nil)
                            self.assignmentTable.reloadData()
                            
                        }catch{
                            
                        }
                    })
                    
                }else{
                    let tabBar = self.presentingViewController as! GradeViewController
                    let presVC = tabBar.selectedViewController as! GradeTableViewController
                    presVC.refresh({ (b : Bool) in
                        DispatchQueue.main.async(execute: {
                            self.cookie = presVC.cookie
                            self.getClassInformation(course: course, section: section)
                        })
                    })
                    
                }
            }
        })
        
        dataTask.resume()
    }
    func handleLongPress(_ sender:UILongPressGestureRecognizer){
        if(sender.state == .began){
            let press = sender.location(in: self.assignmentTable)
            if let indexPath = self.assignmentTable.indexPathForRow(at: press){
                let cell = self.assignmentTable.cellForRow(at: indexPath) as! DetailGradeTableViewCell
                let blurEffect = UIBlurEffect(style: .light)
                self.blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = self.assignmentTable.bounds;
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.assignmentTable.addSubview(blurEffectView)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let detailvc = storyboard.instantiateViewController(withIdentifier: "AssignmentDetail") as! AssignmentDetailModalViewController
                var assignment = NSDictionary()
                assignment = assignments[indexPath.row] as! NSDictionary
                detailvc.calendarReady = cell.calendarReady
                detailvc.assignment = assignment
                detailvc.assignorNo = true;
                self.assignmentTable.deselectRow(at: indexPath, animated: true)
                present(detailvc, animated: true, completion: nil)
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assignments.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OverviewCell", for: indexPath) as! DetailGradeTableViewCell;
        let object = assignments[indexPath.row];
        cell.assignment = object as! NSDictionary
        let assignDictionary = (object as AnyObject).object(forKey: "assignment") as! NSDictionary
        cell.assignmentTitle.text = assignDictionary.object(forKey: "title") as? String
        cell.detail.text = assignDictionary.object(forKey: "details") as? String;
        cell.type.text = (object as AnyObject).object(forKey: "category") as? String;
        var g = (object as AnyObject).object(forKey: "percent") as! String;
        if let a = String(g){
            cell.grade.grade.text = a
        }else{
            cell.grade.grade.text = "A"
        }
        cell.date.text = (object as AnyObject).object(forKey: "stringDate") as? String;
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy"
        let dat = dateFormatter.date(from: cell.date.text!)
        if((dat) != nil){
            if(dat!.compare(Date()) == .orderedAscending){
                cell.calendarReady = false;
            }else{
                cell.calendarReady = true;
            }
        }else{
            cell.calendarReady = false;
        }
        cell.grade.layer.borderWidth = 0;
        if(g.contains("%")){
            g = String(g.characters.dropLast());
            let color = UIColor().getColor(grade: Double(g)!)
            cell.grade.backgroundColor = color
            cell.color = color
            cell.grade.grade.textColor = UIColor().getTextColor(color: color)
        }else{
            cell.grade.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            let color = UIColor().getColor(grade: 0)
            cell.grade.layer.borderColor = color.cgColor
            cell.color = color
            cell.grade.layer.borderWidth = 2;
        }
        cell.backgroundColor = cell.backgroundColor;

        
        return cell;
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let actualCell = cell as! DetailGradeTableViewCell
        actualCell.move()
        actualCell.backgroundColor = actualCell.contentView.backgroundColor;

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func segueBack(){
        self.dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ProjectionSegue", sender: self)
    }
    func ridOfBlur(){
        self.blurEffectView.removeFromSuperview()  
    }
    override func viewDidAppear(_ animated: Bool) {
        if(self.assignmentTable.indexPathForSelectedRow != nil){
            self.assignmentTable.deselectRow(at: self.assignmentTable.indexPathForSelectedRow!, animated: true)
        }
    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.assignmentTable.indexPathForRow(at: location) else {return nil}
       
        guard let cell = self.assignmentTable.cellForRow(at: indexPath) as? DetailGradeTableViewCell else {return nil}
        self.selectedCell = cell;
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        /*let rectOfCellInTableView: CGRect = self.assignmentTable.rectForRowAtIndexPath(indexPath)
        let rectOfCellInSuperview: CGRect = self.assignmentTable.convertRect(rectOfCellInTableView, toView: self.view)*/
        previewingContext.sourceRect = cell.frame;
        // let detailvc = storyboard.instantiateViewControllerWithIdentifier("AssignmentDetail") as! AssignmentDetailModalViewController
        let detailvc = storyboard.instantiateViewController(withIdentifier: "ForceTouchAssignment") as! ForceTouchAssignmentsDetailViewController
        var assignment = NSDictionary()
        assignment = assignments[indexPath.row] as! NSDictionary
        detailvc.calendarReady = cell.calendarReady
        detailvc.assignment = assignment
        detailvc.assignorNo = true;
        return detailvc;

    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let projectionvc = storyboard.instantiateViewController(withIdentifier: "ProjectionAssignmentView") as! ProjectionGradeViewController
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
        show(projectionvc, sender: self)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "ProjectionSegue"){
            let projectionvc = segue.destination as! ProjectionGradeViewController
            let selectedIndexPath = self.assignmentTable.indexPathForSelectedRow
            let selectedCell = self.assignmentTable.cellForRow(at: selectedIndexPath!) as! DetailGradeTableViewCell
            self.assignmentTable.deselectRow(at: selectedIndexPath!, animated: true)
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
