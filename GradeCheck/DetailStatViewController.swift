//
//  DetailStatViewController.swift
//  GradeCheck
//
//  Created by Ivan Chau on 3/21/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit
import Charts


class DetailStatViewController: UIViewController, ChartViewDelegate {
    var data : NSDictionary!
    @IBOutlet weak var navigationBar : UINavigationBar!
    @IBOutlet weak var navItem : UINavigationItem!
    @IBOutlet weak var graph : LineChartView!
    @IBOutlet weak var meanView : MeanView!;
    @IBOutlet weak var rankView : RankView!;
    @IBOutlet weak var percentileView : PercentileView!
    var gradesArray = NSArray()
    var cookie : String!
    var results : [GraphData] = [];
    var className : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(data)
        self.meanView.layer.cornerRadius = 0.5 * self.meanView.bounds.size.width;
        self.rankView.layer.cornerRadius = 0.5 * self.rankView.bounds.size.width;
        self.percentileView.layer.cornerRadius = 0.5 * self.percentileView.bounds.size.width;
        // Do any additional setup after loading the view.
        self.graph.delegate = self;
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
        let classNameString = "className=" + self.className;
        print("className=" + self.className)
        let postData = NSMutableData(data: classNameString.dataUsingEncoding(NSUTF8StringEncoding)!)
        //postData.appendData(idString.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:3000/classdata")!,
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
                            self.getGraphData(self.results)
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
            gradeArray.append(element.grade)
            gradeArray.append(element.grade)
            gradeArray.append(element.grade + 5)
            gradeArray.append(element.grade + 3)
            gradeArray.append(element.grade - 10)

            let entr = ChartDataEntry(value: 3.0, xIndex: 84);
            let ent = ChartDataEntry(value: 2.0, xIndex: 78);
            let en = ChartDataEntry(value: 1.0, xIndex: 62);
            data.append(entr)
            data.append(ent)
            data.append(en)

        }
        gradeArray.sortInPlace()
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
        
        let indexSelfLimit = gradeArray.indexOf(Int(selfLimit)!)
        print(indexSelfLimit)

    }
    func updateMeanView(mean:String){
        self.meanView.meanLabel.text = mean;
    }
    func updateRankView(rank : String, totalString : String){
        
    }
    @IBAction func segueToGradeView(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    

}
