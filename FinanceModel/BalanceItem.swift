//
//  BalanceItem.swift
//  bookkeeping
//
//  Created by Sven van der Heide on 23-03-16.
//  Copyright © 2016 Sven van der Heide. All rights reserved.
//

import ObjectMapper
import Foundation

public class BalanceItem: NSObject, Mappable {
    var isDebet:Bool = false
    var name:String = "hoi"
    var id:String = UUID().uuidString
    var journalEntryComponents = [JournalEntryComponent]()
    var isProfitLoss:Bool?
    var mainBalanceItem:BalanceItem?
    var relatedBalanceItem = [BalanceItem]()
    
    public init(mainBalanceItem newIsDebet:Bool, newName:String){
        isDebet = newIsDebet
        name = newName
        id = UUID().uuidString
        super.init()
        //let content = "[" + Mapper().toJSONString(self, prettyPrint: false)! + "]"
        //saveBalanceItem(content: content)
        balanceItemList.append(self)
        print("created new balance Item: ", newName)
    }
    
    init(subBalanceItem newIsDebet:Bool, newName:String, mainBalanceItem:BalanceItem){
        isDebet = newIsDebet
        name = newName
        id = UUID().uuidString
        super.init()
        mainBalanceItem.relatedBalanceItem.append(self)
        self.mainBalanceItem = mainBalanceItem
        print("created new sub balance Item: ", newName)
    }
    
    required public init?(map: Map) {
        super.init()
        self.mapping(map: map)
        balanceItemList.append(self)
        
    }
    
    func addJournalEntryComponent(_ journalEntryComponent:JournalEntryComponent){
        journalEntryComponents.append(journalEntryComponent)
    }
    
    func deleteJournalEntryComponent(_ journalEntryComponent:JournalEntryComponent)->Bool{
        if let index =  journalEntryComponents.index(of: journalEntryComponent){
            journalEntryComponents.remove(at: index)
            return true
        }else{
            print("deleteJournalEntryComponent | could not find: " +  journalEntryComponent.journalEntry!.name + journalEntryComponent.balanceItem.name)
            return false
        }
    }
    
    func getAmountForDate(_ date:Date)->Float{
        var totalAmount:Float = 0
        let relevantComponents = self.journalEntryComponents.filter { (comp) -> Bool in
            (comp.journalEntry?.date.isLessThanDate(date))!
        }
        for component in relevantComponents{
            totalAmount += component.isDebet == self.isDebet ? component.amount : component.amount * -1;
        }
        return totalAmount
    }
    
    func getTotalAmountForDate(_ date:Date)->Float{
        var totalAmount:Float = 0
        var relevantComponents = self.journalEntryComponents
        for bi in self.relatedBalanceItem{
            relevantComponents += bi.journalEntryComponents
        }
        
        relevantComponents = relevantComponents.filter { (comp) -> Bool in
            (comp.journalEntry?.date.isLessThanDate(date))!
        }
        for component in relevantComponents{
            totalAmount += component.isDebet == self.isDebet ? component.amount : component.amount * -1;
        }
        return totalAmount
    }
    func getRelatedItemList()->[BalanceItem]{
        var relatedItems = relatedBalanceItem
        relatedItems.append(self)
        return relatedItems
    }
    
    
    func getAmountForPeriod(_ date:[Date])->[Float]?{
        var totalPositveAmountAmount:Float = 0
        var totalNegativeAmount:Float = 0
        guard date.count == 2 else{
            return nil}
        
        var dateS = date.sorted { (date1, date2) -> Bool in
            date1.isLessThanDate(date2)
        }
        
        let componentsFiltered = self.journalEntryComponents.filter { (comp) -> Bool in
            let firstStatement = comp.journalEntry!.date.isGreaterThanDate(dateS[0])
            let secondStatement = comp.journalEntry!.date.isLessThanDate(dateS[1])
            return firstStatement && secondStatement
        }

        for component in componentsFiltered{
            totalPositveAmountAmount += component.isDebet == self.isDebet ? component.amount : 0.0
            totalNegativeAmount += component.isDebet != self.isDebet ? component.amount : 0.0
            
        }
        
        
        
        return [totalPositveAmountAmount,totalNegativeAmount]
    }
    
    public func mapping(map: Map) {
        name    <- map["Name"]
        isDebet    <- (map["IsDebit"], BooleanTransform())
        id      <- map["ID"]
        mainBalanceItem <- map["parentBIID"]
    }
    func getWriteStatemnt()->String{
        return "INSERT INTO `perfectdb`.`BalanceItem` (`ID`, `Name`, `IsDebit`, `UID`) VALUES ('\(id)', '\(name)', \(isDebet), 123213);"
    }
    
   
    
    
}


public class BooleanTransform: TransformType{
    public typealias Object = Bool
    public typealias JSON = String
    public func transformFromJSON(_ value: Any?) -> Object?{

        return (value as? String  == "1") ? true : false;
    }
    
    public func transformToJSON(_ value: Object?) -> JSON?{
        return value! ? "1"  : "0";
    }
}

public class BalanceItemTransform: TransformType{
    public typealias Object = BalanceItem
    public typealias JSON = String
    public func transformFromJSON(_ value: Any?) -> Object?{
        let index = balanceItemList.index { (bi) -> Bool in
            bi.id == value as? String
        }
        return index != nil ? balanceItemList[index!] : nil
    }
    
    public func transformToJSON(_ value: Object?) -> JSON?{
        return value?.id
    }
}


var dummyBalanceItemList = [""]
var balanceItemList = [BalanceItem]()
var journalEntryList = [JournalEntry]()

