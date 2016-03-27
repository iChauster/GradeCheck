//
//  DetailGradeTableViewCell.swift
//  GradeCheck
//
//  Created by Ivan Chau on 3/24/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class DetailGradeTableViewCell: UITableViewCell {
    @IBOutlet weak var assignmentTitle : UILabel!
    @IBOutlet weak var grade : GradeView!
    @IBOutlet weak var type : UILabel!
    @IBOutlet weak var detail : UILabel!
    @IBOutlet weak var date : UILabel!
    @IBOutlet weak var views : UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.grade.layer.cornerRadius = 0.5 * self.grade.bounds.size.width;
        CellAnimation.growAndShrink(self.grade)
        self.views.layer.cornerRadius = 10;
        
        
    }
    func move(){
        CellAnimation.growAndShrink(self.grade)
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
class GradeView : UIView{
    @IBOutlet weak var grade : UILabel!
    
}
