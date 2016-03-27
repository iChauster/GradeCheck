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
    override func viewDidLoad() {
        super.viewDidLoad()
        print(data)
        // Do any additional setup after loading the view.
        self.graph.delegate = self;
        self.graph.descriptionText = "Check out your class's grading curve.";
        self.graph.descriptionTextColor = UIColor.whiteColor();
        self.graph.gridBackgroundColor = UIColor.blackColor()

        self.graph.noDataText = "No Data Available";
        let arrayString = ["F","D","C","B","A"]
        let intString = [0.0, 5.0, 9.0, 12.0, 10.0];
        self.getGraphData(arrayString,values: intString)
    }
    func getGraphData(dataPoints : [String], values: [Double]){
        var data : [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let entry = ChartDataEntry(value: values[i], xIndex :i)
            data.append(entry)
        }
        let lineChartDataSet = LineChartDataSet(yVals: data, label: "Number of Students");
        lineChartDataSet.axisDependency = .Left;
        lineChartDataSet.setColor(UIColor.greenColor().colorWithAlphaComponent(0.5));
        lineChartDataSet.setCircleColor(UIColor.whiteColor());
        lineChartDataSet.lineWidth = 1.0;
        lineChartDataSet.circleRadius = 5.0;
        lineChartDataSet.fillAlpha = 65 / 255.0
        lineChartDataSet.fillColor = UIColor.greenColor()
        lineChartDataSet.highlightColor = UIColor.whiteColor();
        lineChartDataSet.drawCircleHoleEnabled = true;
        lineChartDataSet.drawCubicEnabled = true;
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        lineChartData.setValueTextColor(UIColor.whiteColor())
        self.graph.data = lineChartData;
        self.graph.gridBackgroundColor = UIColor.blackColor()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
