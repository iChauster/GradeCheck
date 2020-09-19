//
//  SliderPercentView.swift
//  GradeCheck
//
//  Created by Ivan Chau on 4/23/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import UIKit

class SliderPercentView: UIView {
    @IBOutlet weak var percentLabel : UILabel!
    @IBOutlet weak var parent : ProjectionGradeViewController!
    var currentValue : Double = 100.0
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        touches.first
        touches.count
        for touch in touches {
            let t = touch
            if (touch.view == self){
                let difference = t.previousLocation(in: self).y - t.location(in: self).y
                if(Double(difference) < 0){
                    let finalValue = Double(currentValue) + Double(difference)/2.0;
                    if(finalValue < 0){
                        currentValue = 0
                    }else{
                        currentValue += Double(difference)/2.0
                    }
                }else if(Double(difference) > 0){
                    let finalValue = Double(currentValue) + Double(difference)/2.0
                    if(finalValue > 100){
                        currentValue = 100
                    }else{
                        currentValue += Double(difference)/2.0
                    }
                }
                self.updateLab()
            }
        }
    }
    func updateLab(){
        let text = String(percentLabel.text!.characters.dropLast())
        var value = Double(text)
            value = currentValue
            self.percentLabel.text = String(format: "%.1f", value!) + "%"
                switch(Int(value!)){
                case 0..<50:
                    if(!(self.backgroundColor!.isEqual(UIColor.black))){
                        UIView.animate(withDuration: 1.0, animations: {
                            self.backgroundColor = UIColor.black
                            self.percentLabel.textColor = UIColor.white
                        })
                    }
                case 50..<75 :
                    if(!(self.backgroundColor!.isEqual(UIColor.red))){
                        UIView.animate(withDuration: 1.0, animations: {
                            self.backgroundColor = UIColor.red
                            self.percentLabel.textColor = UIColor.white

                        })
                    }
                case 75..<85 :
                    if(!(self.backgroundColor!.isEqual(UIColor().ICYellow))){
                        UIView.animate(withDuration: 1.0, animations: {
                            self.backgroundColor = UIColor().ICYellow
                            self.percentLabel.textColor = UIColor.black
                        })
                    }
                case 85..<110 :
                    if(!(self.backgroundColor!.isEqual(UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0)))){
                        UIView.animate(withDuration: 1.0, animations: {
                            self.backgroundColor = UIColor(red: 0.1574, green: 0.6298, blue: 0.2128, alpha: 1.0);
                            self.percentLabel.textColor = UIColor.white
                        })
                    }
                default :
                    self.backgroundColor = UIColor.purple
                }
        self.parent.adjustMin();
        
    }
}
