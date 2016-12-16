//
//  journalItem.swift
//  bookkeeping
//
//  Created by Sven van der Heide on 17-03-16.
//  Copyright © 2016 Sven van der Heide. All rights reserved.
//

import ObjectMapper
import Foundation

open class JournalEntry: NSObject, MappableDBSender{
    public var DBService: DBService?
    public var name:String
    public var date:Date
    public var repeatable:Bool?
    public var id:String
    
    
    public var journalEntryComponents:[JournalEntryComponent]?
    
    
    public init?(newName:String, newDate:Date, newJournalEntryComponents:[JournalEntryComponent]) {
        name = newName
        date = newDate
        id = UUID().uuidString
        super.init()
        DBService = SQLService(typeName: "JournalEntry", dbSender: self as MappableDBSender)
        if(checkBalanceComponents(newJournalEntryComponents)){
            journalEntryComponents = newJournalEntryComponents
            journalEntryList.append(self)
            self.addJournalEntryComponentsToBalanceItems()
            self.addJournalEntrytoComponents()
            print("created a new journal entry with name", newName)
            
        }else{
            print("failed to create journal entry with name: ", newName)
            return nil
        }
    }
    required public init?(map: Map){
        name = "hoi"
        date = NSDate() as Date
        id = NSUUID().uuidString
        super.init()
        self.mapping(map: map)
        print(self.journalEntryComponents )
        for jec in journalEntryComponents ?? [JournalEntryComponent](){
            jec.journalEntry = self
            jec.addToBalanceItem()
        }
        journalEntryList.append(self)
    }
    
    public func replaceJournalEntry(_ newName:String, newDate:Date, newJournalEntryComponents:[JournalEntryComponent]){
        if(checkBalanceComponents(newJournalEntryComponents)){
            name = newName
            date = newDate
            self.replaceJournalEntryComponents(newJournalEntryComponents)
            print("created a new journal entry with name", newName)
        }else{
            print("failed to create journal entry with name: ", newName)
        }
    }
    
    func replaceJournalEntryComponents(_ newJournalEntryComponents:[JournalEntryComponent]){
        self.deleteJournalEntryComponentsToBalanceItems()
        self.journalEntryComponents = newJournalEntryComponents
        self.addJournalEntrytoComponents()
        self.addJournalEntryComponentsToBalanceItems()
    }
    
    public func deleteJournalEntry(){
        if let index = journalEntryList.index(of: self){
            journalEntryList.remove(at: index)
        }
        self.deleteJournalEntryComponentsToBalanceItems()
        
    }
    
    fileprivate func addJournalEntrytoComponents(){
        for component in journalEntryComponents!{
            component.journalEntry = self

            //saveJECToDB(component)
        }
    }
    
    
    fileprivate func addJournalEntryComponentsToBalanceItems(){
        for component in journalEntryComponents!{
            component.addToBalanceItem()
        }
    }
    
    fileprivate func deleteJournalEntryComponentsToBalanceItems(){
        for component in journalEntryComponents!{
            component.deleteFromBalanceItem()
        }
    }
    public func checkBalanceComponents(_ journalEntryComponents:[JournalEntryComponent])->Bool{
        var totalValue:Double = 0
        for component  in journalEntryComponents{
            totalValue += component.isDebet ? component.amount : component.amount * -1
        }
        if(journalEntryComponents.count > 1 && Int(round(1000 * totalValue)) == 0){
            return true
        }else{
            print("balance item not in balance" , totalValue)
            return false
        }
    }
    
    public func getWriteStatemnt()->[String]{
        var writeStatement = [String]();
        for jec in journalEntryComponents!{
            //"INSERT INTO `JournalEntryComponent` (`BIID`, `Amount`, `IsDebit`, `JEID`) VALUES (1, $a , $id, 1);";
            writeStatement.append("INSERT INTO `perfectdb`.`JournalEntryComponent` (`ID`, `BIID`, `Amount`, `IsDebit`, `JEID`) VALUES ('\(jec.id )','\((jec.balanceItem?.id ?? jec.balanceItemId)! )', \(jec.amount), \(jec.isDebet), '\(jec.journalEntry!.id)'); ");
        }
        writeStatement.append("INSERT INTO `perfectdb`.`JournalEntry` (`ID`, `Name`, `Date`, `UID`) VALUES ('\(self.id)','\(self.name)', \((DateTransform().transformToJSON(self.date) ?? 12345)!), 123213);");
        return writeStatement;
    }
    
    public func mapping(map: Map) {
        name    <- map["Name"]
        date    <- (map["Date"], DateTransform())
        id      <- map["ID"]
        journalEntryComponents <- map["journalEntryComponents"]

    }

}


