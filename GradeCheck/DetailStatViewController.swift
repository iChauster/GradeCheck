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
    let url = "http://localhost:2800/"

    var gradesArray = NSArray()
    var cookie : String!
    var results : [GraphData] = [];
    var className : String!
    var dataArray = NSArray();
    override func viewDidLoad() {
        super.viewDidLoad()
        print(data)
        print(cookie)
        self.meanView.layer.cornerRadius = 0.5 * self.meanView.bounds.size.width;
        self.rankView.layer.cornerRadius = 0.5 * self.rankView.bounds.size.width;
        self.percentileView.layer.cornerRadius = 0.5 * self.percentileView.bounds.size.width;
        self.statisticsTable.layer.cornerRadius = 10;
        self.navigationBar.tintColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
        self.graph.delegate = self;
        self.statisticsTable.dataSource = self;
        self.statisticsTable.delegate = self;
        self.graph.descriptionText = "Check out your class's grading curve.";
        self.graph.descriptionTextColor = UIColor.whiteColor();
        self.graph.drawGridBackgroundEnabled = true;
        self.graph.gridBackgroundColor = UIColor(red: 0.0, green: 0.5019, blue: 0.2509, alpha: 1.0)
        self.graph.animate(yAxisDuration: 3.0, easingOption: .EaseInOutQuart)
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
            let alert = UIAlertController(title: "No Data!", message: "Grades are not in for the quarter yet!", preferredStyle: .Alert);
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        let classNameString = "className=" + self.className;
        print("className=" + self.className)
        let postData = NSMutableData(data: classNameString.dataUsingEncoding(NSUTF8StringEncoding)!)
        //postData.appendData(idString.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let request = NSMutableURLRequest(URL: NSURL(string: url + "classdata")!,
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
                            let graphDataCont = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray;
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
                                let alert = UIAlertController(title: "No Data!", message: "Grades are not in for the quarter yet!", preferredStyle: .Alert);
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                alert.addAction(okAction)
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                            CellAnimation.growAndShrink(self.meanView)
                            CellAnimation.growAndShrink(self.rankView)
                            CellAnimation.growAndShrink(self.percentileView)
                        }catch{
                            
                        }
                    })
                    
                }else if(httpResponse?.statusCode == 440){
                    dispatch_async(dispatch_get_main_queue(), {
                        do{
                            let cookie = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray;
                            print(cookie);
                            let cooke = cookie[0] as! NSDictionary
                            let hafl = cooke.objectForKey("set-cookie") as! NSArray;
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
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    func getClassData(){
        print("getClassDataCalled")
        let delimiter = " -"
        let classString = self.data.objectForKey("class");
        let token = classString?.componentsSeparatedByString(delimiter)
        let final =  token![0];
        print(final);
        let secondDemiliter = "/";
        let tok = final.componentsSeparatedByString(secondDemiliter);
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
        let idString = "&id=" + (NSUserDefaults .standardUserDefaults().objectForKey("id")as! String);
        let cookieString = "&cookie=" + self.cookie
        
        let postData = NSMutableData(data: classNameString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(courseString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(sectionString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(idString.dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(cookieString.dataUsingEncoding(NSUTF8StringEncoding)!)
        //please stop looking at my fucking code you creep (ง •̀_•́)ง
        let request = NSMutableURLRequest(URL: NSURL(string: url + "classAverages")!,
                                          cachePolicy: .UseProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.HTTPBody = postData
        // < <> >
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
                            let graphDataCont = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray;
                            self.dataArray = graphDataCont
                            self.statisticsTable.reloadData();
                        }catch{
                            
                        }
                    })
                    
                }else if(httpResponse?.statusCode == 440){
                    dispatch_async(dispatch_get_main_queue(), {
                        do{
                            let cookie = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray;
                            print(cookie);
                            let cooke = cookie[0] as! NSDictionary
                            let hafl = cooke.objectForKey("set-cookie") as! NSArray;
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
    func getGraphData(dataPoints : [GraphData]){
        var data : [ChartDataEntry] = []
        /*for i in 0..<dataPoints.count {
            let entry = ChartDataEntry(value: values[i], xIndex :i)
            data.append(entry)
        }*/
        var gradeArray:[Int] = []
        var gradeSum : Int = 0;
        for i in 0..<dataPoints.count {
            let element = dataPoints[i];
            let entry = ChartDataEntry(value:Double(element.occurences),xIndex:element.grade)
            data.append(entry)
            gradeSum += element.grade;
            gradeArray.append(element.grade);
        }
        gradeArray.sortInPlace()
        print(gradeArray)
        gradeArray = gradeArray.reverse()
        print(gradeArray)
        let meanGrade = Double(gradeSum) / Double(dataPoints.count);
        let meanString = String(format: "%.1f", meanGrade)
        self.updateMeanView(meanString)
        var array : [String] = [];
        for i in 0..<110 {
            array.append(String(i))
        }
        let lineChartDataSet = LineChartDataSet(yVals: data, label: "Number of Students");
        lineChartDataSet.setColor(UIColor.whiteColor().colorWithAlphaComponent(0.5));
        lineChartDataSet.setCircleColor(UIColor.greenColor());
        lineChartDataSet.lineWidth = 2.0;
        lineChartDataSet.circleRadius = 5.0;
        lineChartDataSet.fillAlpha = 65 / 255.0
        lineChartDataSet.fillColor = UIColor.greenColor()
        lineChartDataSet.highlightColor = UIColor.whiteColor();
        lineChartDataSet.drawCircleHoleEnabled = true;
        lineChartDataSet.drawCubicEnabled = true;
        let lineChartData = LineChartData(xVals: array, dataSet: lineChartDataSet)
        lineChartData.setValueTextColor(UIColor.whiteColor())
        self.graph.data = lineChartData;
        var selfLimit = self.data["grade"] as! String
        selfLimit = String(selfLimit.characters.dropLast())
        let limitLine = ChartLimitLine(limit: Double(selfLimit)! , label: "You")
        limitLine.lineColor = UIColor.redColor()
        limitLine.valueTextColor = UIColor.whiteColor()
        limitLine.enabled = true;
        limitLine.lineWidth = 2.0;
        self.graph.xAxis.addLimitLine(limitLine)
        
        var indexSelfLimit = Int(gradeArray.indexOf(Int(selfLimit)!)!)
        indexSelfLimit += 1;
        
        self.updateRankView(String(indexSelfLimit), totalString: String(dataPoints.count))
        self.updatePercentileView(gradeArray,controlGrade: Int(selfLimit)!);
    }
    func updateMeanView(mean:String){
        self.meanView.meanLabel.text = mean;
    }
    func updateRankView(rank : String, totalString : String){
        print(rank + totalString)
        self.rankView.rankLabel.text = rank;
        self.rankView.totalLabel.text = totalString;
    }
    func updatePercentileView(gradeArray : [Int], controlGrade: Int){
       // PR% = Lower Rank + ( 0.5 x Same Rank ) / N (Total)
        /*let arr2 = [1,2,3,4,5,6,7,8,9,10]
        let indexOfFirstGreaterThanFive = arr2.indexOf({$0 > 5}) // 5
        let indexOfFirstGreaterThanOneHundred = arr2.indexOf({$0 > 100}) // nil*/
        //deal with when you have the highest grade, etc.
        let indexesAboveControl = gradeArray.indexOf({$0 > controlGrade})
        if(indexesAboveControl != nil){
            let indexOfGrade = gradeArray.indexOf(controlGrade)
            print(indexesAboveControl)
            print(indexOfGrade)
            let numberAbove = gradeArray.count - indexesAboveControl!
            print(numberAbove)
            let numberSame = indexesAboveControl! - indexOfGrade!;
            let numberBelow = gradeArray.count - numberAbove - numberSame;
            print(numberBelow)
            let percentile = (Double(numberBelow) + (0.5 * Double(numberSame))) / Double(gradeArray.count);
            let percentageString = String(format: "%.1f", percentile * 100)
            self.percentileView.percentLabel.text = percentageString + "%";
            print(percentile)
        }else{
            self.percentileView.percentLabel.text = "100%";
        }
    }
    @IBAction func segueToGradeView(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.dataArray.count == 0){
            return 0;
        }else{
            return 3;
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailStatCell", forIndexPath: indexPath) as! DetailStatTableViewCell
        let given = self.dataArray[indexPath.section] as! NSDictionary;
        print(given)
        cell.backgroundColor = UIColor(red: 55.0/255, green: 127.0/255, blue: 58.0/255, alpha: 1.0);
        let grades = given["grades"] as! NSDictionary
        var arrayOfGrades = grades["grades"] as! [Double];
        arrayOfGrades.sortInPlace();
        print(arrayOfGrades)
        if(indexPath.row == 0){
            cell.titleLabel.text = "Average " + (given["category"] as! String) + " Score :";
            var averageScore = (grades["gradeAchieved"] as! Double)/(grades["gradeMax"]as! Double)
            averageScore *= 100;
            cell.dataView.dataLabel.text = String(format: "%.1f", averageScore) + "%";
            switch Int(averageScore){
            case 0..<50:
                cell.dataView.backgroundColor = UIColor.blackColor()
            case 51..<75 :
                cell.dataView.backgroundColor = UIColor.redColor()
            case 76..<85 :
                cell.dataView.backgroundColor = UIColor.yellowColor()
            case 86..<110 :
                cell.dataView.backgroundColor = UIColor(red:0.1574, green:0.6298, blue:0.2128, alpha: 1.0)
            default :
                cell.dataView.backgroundColor = UIColor.purpleColor()
            }
        }else if(indexPath.row == 1){
            cell.titleLabel.text = "Highest Score : ";
            let finalElement = arrayOfGrades.last
            cell.dataView.dataLabel.text = String(format: "%.1f", finalElement!) + "%";
            switch Int(finalElement!){
            case 0..<50:
                cell.dataView.backgroundColor = UIColor.blackColor()
            case 51..<75 :
                cell.dataView.backgroundColor = UIColor.redColor()
            case 76..<85 :
                cell.dataView.backgroundColor = UIColor.yellowColor()
            case 86..<110 :
                cell.dataView.backgroundColor = UIColor(red:0.1574, green:0.6298, blue:0.2128, alpha: 1.0)
            default :
               cell.dataView.backgroundColor = UIColor.purpleColor()
            }

        }else if(indexPath.row == 2){
            cell.titleLabel.text = "Lowest Score : ";
            let firstElement = arrayOfGrades.first;
            cell.dataView.dataLabel.text = String(format:"%.1f", firstElement!) + "%";
            switch Int(firstElement!){
            case 0..<50:
                cell.dataView.backgroundColor = UIColor.blackColor()
            case 51..<75 :
                cell.dataView.backgroundColor = UIColor.redColor()
            case 76..<85 :
                cell.dataView.backgroundColor = UIColor.yellowColor()
            case 86..<110 :
                cell.dataView.backgroundColor = UIColor(red:0.1574, green:0.6298, blue:0.2128, alpha: 1.0)
            default :
                cell.dataView.backgroundColor = UIColor.purpleColor()
            }
            
        }else{
            let a = UIAlertController(title: "Something Got MESSED UP", message: "Whoops.", preferredStyle: .Alert)
            self.presentViewController(a, animated: true, completion: nil);
        }
        cell.backgroundColor = cell.backgroundColor;
        return cell
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let actualCell = cell as! DetailStatTableViewCell
        CellAnimation.growAndShrink(actualCell.dataView)
        actualCell.backgroundColor = actualCell.contentView.backgroundColor;

    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataArray.count;
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = UIColor.whiteColor()
        headerView.backgroundView?.backgroundColor = UIColor.blackColor()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    

}
