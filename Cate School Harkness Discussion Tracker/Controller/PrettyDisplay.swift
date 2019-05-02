//
//  PrettyDisplay.swift
//  Cate School Harkness Discussion Tracker
//
//  Created by cate on 4/28/19.
//  Copyright © 2019 cate. All rights reserved.
//

import Foundation
import UIKit

class PrettyDisplayStuff {
//    func addBoldText(normalText: String, boldText : String) -> NSAttributedString {
//       
//        //https://stackoverflow.com/questions/28496093/making-text-bold-using-attributed-string-in-swift/37992022
//        let attributedString = NSMutableAttributedString(string: normalText)
//        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
//        let boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
//        
//        attributedString.append(boldString)
//        
//        return attributedString
//    }
    func convertSecondsToReadableTime(timeInSeconds: Double) -> String {
        let convertTime = lrint(timeInSeconds)
        let hour = convertTime/3600
        let minutes = (convertTime % 3600) / 60
        let seconds = convertTime % 60
        
        
        var secondPart = "\(seconds)"
        var minutePart = "\(minutes)"
        //I'm just gonna add a zero under the assumption she's not having a discussion over 10 hours
        let hourPart = "0\(hour)"
        //The following complicatedness is for my own aesthetic reasons, I'm sure there is a clever way to deal with this but I have bigger problems
        
        if seconds < 10 {
            secondPart = "0\(seconds)"
        }
        if minutes < 10 {
            minutePart = "0\(minutes)"
        }
        
        //I'm just gonna assune she's not gonna have a discussion longer than 10 hours
        let elapsedTime = hourPart + ":" + minutePart + ":" + secondPart
        return elapsedTime
    }
}
