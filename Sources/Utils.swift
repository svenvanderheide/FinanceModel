//
//  Utils.swift
//  bookkeeping
//
//  Created by Sven van der Heide on 02-04-16.
//  Copyright © 2016 Sven van der Heide. All rights reserved.
//
import Cocoa

public func createNumberFormatter()->NumberFormatter{
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    // Configure the number formatter to your liking
    return nf
}

public func createDateFormatter()->DateFormatter{
    let df = DateFormatter()
    df.dateStyle = .medium
    // Configure the number formatter to your liking
    return df
}

public extension Date {
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(_ daysToAdd: Int) -> Date {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(_ hoursToAdd: Int) -> Date {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}

public func jsonIfyArray(_ keys:[String], values:[String])->String{
    var json = "{"
    if(keys.count == values.count){
        for index in 0...(keys.count - 2){
            json += "\(keys[index]):\(values[index]),"
        }
        json += "\(keys[keys.count - 1]):\(values[keys.count - 1])"

    }
    json += "}"
    return json
}
