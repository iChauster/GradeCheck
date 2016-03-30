//
//  GraphData.swift
//  GradeCheck
//
//  Created by Ivan Chau on 3/29/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class GraphData: NSObject {
    var grade : Int!
    var occurences : Int!
    init(grade : Int! , occurences : Int!){
        self.grade = grade;
        self.occurences = occurences;
    }
}
class MeanView : UIView{
    @IBOutlet weak var meanLabel : UILabel!;
}
class RankView : UIView{
    @IBOutlet weak var rankLabel : UILabel!;
    @IBOutlet weak var totalLabel : UILabel!;
}
class PercentileView : UIView{
    @IBOutlet weak var percentLabel : UILabel!;
}
