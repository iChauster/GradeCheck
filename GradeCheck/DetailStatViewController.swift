//
//  DetailStatViewController.swift
//  GradeCheck
//
//  Created by Ivan Chau on 3/21/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit
import Charts


class DetailStatViewController: UIViewController, ChartViewDelegate, UITableViewDelegate, UITableViewDataSource {
    var data : NSDictionary!
    @IBOutlet weak var navigationBar : UINavigationBar!
    @IBOutlet weak var navItem : UINavigationItem!
    @IBOutlet weak var graph : LineChartView!
    @IBOutlet weak var meanView : MeanView!;
    @IBOutlet weak var rankView : RankView!;
    @IBOutlet weak var percentileView : PercentileView!
    @IBOutlet weak var statisticsTable : UITableView!
    let url = "http://gradecheck.herokuapp.com/"
    //let url = "http://localhost:2800/"
    var gradesArray = NSArray()
    var cookie : String!
    var results : [GraphData] = [];
    var className : String!
    var dataArray = NSArray();
    var markingPeriod : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        print(data)
        print(cookie)
        self.meanView.layer.cornerRadius = 0.5 * self.meanView.bounds.size.width;
        self.rankView.layer.cornerRadius = 0.5 * self.rankView.bounds.size.width;
        self.percentileView.layer.cornerRadius = 0.5 * self.percentileView.bounds.size.width;
        self.statisticsTable.layer.cornerRadius = 10;
        self.navigationBar.tintColor = UIColor.white
        // Do any additional setup after loading the view.
        self.graph.delegate = self;
        self.statisticsTable.dataSource = self;
        self.statisticsTable.delegate = self;
        self.graph.descriptionText = "Check out your class's grading curve.";
        self.graph.descriptionTextColor = UIColor.white;
        self.graph.drawGridBackgroundEnabled = true;
        self.graph.gridBackgroundColor = UIColor(red: 0.0, green: 0.5019, blue: 0.2509, alpha: 1.0)
        self.graph.animate(yAxisDuration: 3.0, easingOption: .easeInOutQuart)
        self.graph.noDataText = "No Data Available";
        self.navItem.title = self.className
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        //let cookieString = "cookie=" + self.cookie
        //let idString = "&id=" + (NSUserDefaults.standardUserDefaults().objectForKey("id") as! String);
        if((self.data["grade"]as! String) != "No Grades"){
            self.getClassData();
        }else{
            let alert = UIAlertController(title: "No Data!", message: "Grades are not in for the quarter yet!", preferredStyle: .alert);
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        let classNameString = "className=" + self.className;
        print("className=" + self.className)
        let postData = NSData(data: classNameString.data(using: String.Encoding.utf8)!) as Data
        //postData.appendData(idString.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let request = NSMutableURLRequest(url: URL(string: url + "classdata")!,
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
                            let graphDataCont = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray;
                            for i in 0..<graphDataCont.count{
                                let element = graphDataCont[i] as! NSDictionary;
                                print(element)
                                let gra = element["grade"] as! String
                                let occr = element["occurences"]as! Int;
                                let graphDataObject = GraphData(grade:Int(gra), occurences: occr)
                                self.results.append(graphDataObject)
                            }
                            print(self.results)
                            if((self.data["grade"]as! String) != "No Grades"){

                            self.getGraphData(self.results)
                            
                            }else{
                                let alert = UIAlertController(title: "No Data!", message: "Grades are not in for the quarter yet!", preferredStyle: .alert);
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                            CellAnimation.growAndShrink(self.meanView)
                            CellAnimation.growAndShrink(self.rankView)
                            CellAnimation.growAndShrink(self.percentileView)
                        }catch{
                            
                        }
                    })
                    
                }else if(httpResponse?.statusCode == 440){
                    DispatchQueue.main.async(execute: {
                        do{
                            let cookie = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray;
                            print(cookie);
                            let cooke = cookie[0] as! NSDictionary
                            let hafl = cooke.object(forKey: "set-cookie") as! NSArray;
                            self.cookie = hafl[0] as! String;
                            print(self.cookie);
                            
                        }catch{
                            
                        }
                    })
                    
                }
            }
        })
        
        dataTask.resume()
    
    }
    override var prefersStatusBarHidden : Bool {
        return true
    }
    func getClassData(){
        print("getClassDataCalled")
        let classString = self.data.object(forKey: "classCodes");
        let secondDemiliter = ":";
        let tok = (classString! as AnyObject).components(separatedBy: secondDemiliter);
        let course = tok[0]
        let section = tok[1];
        print(course + " " + section)
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let classNameString = "className=" + self.className;
        print("className=" + self.className)
        let courseString = "&course=" + course;
        let sectionString = "&section=" + section;
        let idString = "&id=" + (UserDefaults.standard.object(forKey: "id")as! String);
        let cookieString = "&cookie=" + self.cookie
        
        
        var postData = NSData(data: classNameString.data(using: String.Encoding.utf8)!) as Data
        postData.append(courseString.data(using: String.Encoding.utf8)!)
        postData.append(sectionString.data(using: String.Encoding.utf8)!)
        postData.append(idString.data(using: String.Encoding.utf8)!)
        postData.append(cookieString.data(using: String.Encoding.utf8)!)
        if(self.markingPeriod != nil){
            let stringMarkingPeriod = "&markingPeriod=" + self.markingPeriod!
            postData.append(stringMarkingPeriod.data(using: String.Encoding.utf8)!)
        }
        //please stop looking at my fucking code you creep (ง •̀_•́)ง
        let request = NSMutableURLRequest(url: URL(string: url + "classAverages")!,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        // < <> >
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
                            let graphDataCont = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray;
                            self.dataArray = graphDataCont
                            self.statisticsTable.reloadData();
                        }catch{
                            
                        }
                    })
                    
                }else if(httpResponse?.statusCode == 440){
                    DispatchQueue.main.async(execute: {
                        do{
                            let cookie = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray;
                            print(cookie);
                            let cooke = cookie[0] as! NSDictionary
                            let hafl = cooke.object(forKey: "set-cookie") as! NSArray;
                            self.cookie = hafl[0] as! String;
                            print(self.cookie);
                            
                        }catch{
                            
                        }
                    })
                    
                }
            }
        })
        
        dataTask.resume()

        
    }
    func getGraphData(_ dataPoints : [GraphData]){
        var data : [ChartDataEntry] = []
        /*for i in 0..<dataPoints.count {
            let entry = ChartDataEntry(value: values[i], xIndex :i)
            data.append(entry)
        }*/
        var gradeArray:[Int] = []
        var gradeSum : Int = 0;
        for i in 0..<dataPoints.count {
            let element = dataPoints[i];
            let entry = ChartDataEntry(x:Double(element.grade),y:Double(element.occurences))
            data.append(entry)
            gradeSum += element.grade;
            gradeArray.append(element.grade);
        }
        gradeArray.sort()
        print(gradeArray)
        gradeArray = gradeArray.reversed()
        print(gradeArray)
        let meanGrade = Double(gradeSum) / Double(dataPoints.count);
        let meanString = String(format: "%.1f", meanGrade)
        self.updateMeanView(meanString)
        var array : [String] = [];
        for i in 0..<110 {
            array.append(String(i))
        }
        let lineChartDataSet = LineChartDataSet(values: data, label: "Number of Students");
        lineChartDataSet.setColor(UIColor.white.withAlphaComponent(0.5));
        lineChartDataSet.setCircleColor(UIColor.green);
        lineChartDataSet.lineWidth = 2.0;
        lineChartDataSet.circleRadius = 5.0;
        lineChartDataSet.fillAlpha = 65 / 255.0
        lineChartDataSet.fillColor = UIColor.green
        lineChartDataSet.highlightColor = UIColor.white;
        lineChartDataSet.drawCircleHoleEnabled = true;
        lineChartDataSet.mode = .cubicBezier
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        lineChartData.setValueTextColor(UIColor.white)
        self.graph.data = lineChartData;
        var selfLimit = self.data["grade"] as! String
        selfLimit = String(selfLimit.characters.dropLast())
        let limitLine = ChartLimitLine(limit: Double(selfLimit)! , label: "You")
        limitLine.lineColor = UIColor.red
        limitLine.valueTextColor = UIColor.white
        limitLine.enabled = true;
        limitLine.lineWidth = 2.0;
        self.graph.xAxis.addLimitLine(limitLine)
        if(gradeArray.index(of:Int(selfLimit)!) != nil){
            var indexSelfLimit = Int(gradeArray.index(of: Int(selfLimit)!)!)
            indexSelfLimit += 1;
        
            self.updateRankView(String(indexSelfLimit), totalString: String(dataPoints.count))
        }
        self.updatePercentileView(gradeArray.reversed(),controlGrade: Int(selfLimit)!);
    }
    func updateMeanView(_ mean:String){
        self.meanView.meanLabel.text = mean;
    }
    func updateRankView(_ rank : String, totalString : String){
        print(rank + totalString)
        self.rankView.rankLabel.text = rank;
        self.rankView.totalLabel.text = totalString;
    }
    func updatePercentileView(_ gradeArray : [Int], controlGrade: Int){
       // PR% = Lower Rank + ( 0.5 x Same Rank ) / N (Total)
        /*let arr2 = [1,2,3,4,5,6,7,8,9,10]
        let indexOfFirstGreaterThanFive = arr2.indexOf({$0 > 5}) // 5
        let indexOfFirstGreaterThanOneHundred = arr2.indexOf({$0 > 100}) // nil*/
        //deal with when you have the highest grade, etc.
        let indexesAboveControl = gradeArray.index(where: {$0 > controlGrade})
        if(indexesAboveControl != nil){
            
            if let indexOfGrade = gradeArray.index(of: controlGrade){
            print(indexesAboveControl)
            print(indexOfGrade)
            let numberAbove = gradeArray.count - indexesAboveControl!
            print(numberAbove)
            let numberSame = indexesAboveControl! - indexOfGrade;
            let numberBelow = gradeArray.count - numberAbove - numberSame;
            print(numberBelow)
            let percentile = (Double(numberBelow) + (0.5 * Double(numberSame))) / Double(gradeArray.count);
            let percentageString = String(format: "%.1f", percentile * 100)
            self.percentileView.percentLabel.text = percentageString + "%";
            print(percentile)
            }
        }else{
            self.percentileView.percentLabel.text = "100%";
        }
    }
    @IBAction func segueToGradeView(){
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.dataArray.count == 0){
            return 0;
        }else{
            return 3;
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailStatCell", for: indexPath) as! DetailStatTableViewCell
        let given = self.dataArray[indexPath.section] as! NSDictionary;
        print(given)
        cell.backgroundColor = UIColor(red: 55.0/255, green: 127.0/255, blue: 58.0/255, alpha: 1.0);
        let grades = given["grades"] as! NSDictionary
        var arrayOfGrades = grades["grades"] as! [Double];
        arrayOfGrades.sort();
        print(arrayOfGrades)
        if(indexPath.row == 0){
            cell.titleLabel.text = "Average " + (given["category"] as! String) + " Score :";
            var averageScore = (grades["gradeAchieved"] as! Double)/(grades["gradeMax"]as! Double)
            averageScore *= 100;
            cell.dataView.dataLabel.text = String(format: "%.1f", averageScore) + "%";
            switch Int(averageScore){
            case 0..<50:
                cell.dataView.backgroundColor = UIColor.black
            case 51..<75 :
                cell.dataView.backgroundColor = UIColor.red
            case 76..<85 :
                cell.dataView.backgroundColor = UIColor.yellow
            case 86..<110 :
                cell.dataView.backgroundColor = UIColor(red:0.1574, green:0.6298, blue:0.2128, alpha: 1.0)
            default :
                cell.dataView.backgroundColor = UIColor.purple
            }
        }else if(indexPath.row == 1){
            cell.titleLabel.text = "Highest Score : ";
            let finalElement = arrayOfGrades.last
            cell.dataView.dataLabel.text = String(format: "%.1f", finalElement!) + "%";
            switch Int(finalElement!){
            case 0..<50:
                cell.dataView.backgroundColor = UIColor.black
            case 51..<75 :
                cell.dataView.backgroundColor = UIColor.red
            case 76..<85 :
                cell.dataView.backgroundColor = UIColor.yellow
            case 86..<110 :
                cell.dataView.backgroundColor = UIColor(red:0.1574, green:0.6298, blue:0.2128, alpha: 1.0)
            default :
               cell.dataView.backgroundColor = UIColor.purple
            }

        }else if(indexPath.row == 2){
            cell.titleLabel.text = "Lowest Score : ";
            let firstElement = arrayOfGrades.first;
            cell.dataView.dataLabel.text = String(format:"%.1f", firstElement!) + "%";
            switch Int(firstElement!){
            case 0..<50:
                cell.dataView.backgroundColor = UIColor.black
            case 51..<75 :
                cell.dataView.backgroundColor = UIColor.red
            case 76..<85 :
                cell.dataView.backgroundColor = UIColor.yellow
            case 86..<110 :
                cell.dataView.backgroundColor = UIColor(red:0.1574, green:0.6298, blue:0.2128, alpha: 1.0)
            default :
                cell.dataView.backgroundColor = UIColor.purple
            }
            
        }else{
            let a = UIAlertController(title: "Something Got MESSED UP", message: "Whoops.", preferredStyle: .alert)
            self.present(a, animated: true, completion: nil);
        }
        cell.backgroundColor = cell.backgroundColor;
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let actualCell = cell as! DetailStatTableViewCell
        CellAnimation.growAndShrink(actualCell.dataView)
        actualCell.backgroundColor = actualCell.contentView.backgroundColor;

    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count;
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(self.dataArray.count > 0){
            let dealing = self.dataArray[section] as! NSDictionary
            let string = dealing["category"] as! String
            if(section == 0){
                return string + " Statistics"
            }
            else if (section == 1){
                return string + " Statistics"
            }else{
                return string + " Statistics"
            }
        }else{
            return "";
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = UIColor.white
        headerView.backgroundView?.backgroundColor = UIColor.black
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    

}
