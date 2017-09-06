//
//  IColor.swift
//  GradeCheck
//
//  Created by Ivan Chau on 12/10/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init?(hex: String?){
        var rgbValue: CUnsignedLongLong = 0
        let scanner = Scanner(string: hex!)
        if hex?.hasPrefix("#") == true {scanner.scanLocation = 1}
        scanner.scanHexInt64(&rgbValue)
        let color = UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16)/255.0,
                            green: CGFloat((rgbValue & 0x00FF00) >> 8)/255.0,
                            blue: CGFloat(rgbValue & 0x0000FF)/255.0, alpha: 1.0)
        self.init(cgColor: color.cgColor)
    }
    func getColor(grade: Double?) -> UIColor {
        switch Int(grade!) {
        case 0..<50:
            return self.ICBlack
        case 51..<75 :
            return self.ICRed
        case 76..<85 :
            return self.ICYellow
        case 86..<110 :
            return self.ICGreen
        default :
            return self.ICPurple
        }
    }
    func getTextColor(color : UIColor) -> UIColor {
        if(color.isEqual(ICYellow)){
            return ICBlack;
        }else{
            return UIColor.white
        }
    }
    var ICPurple : UIColor {return UIColor(hex:"#5856D6")!}
    var ICBlack : UIColor {return UIColor(hex:"#1F1F21")!}
    var ICRed : UIColor {return UIColor(hex:"#F4564D")!}
    var ICYellow : UIColor{return UIColor(hex:"#FFCD02")!}
    var ICGreen : UIColor{return UIColor(hex:"#009c2a")!}
}
