//
//  JournalItemComponent.swift
//  bookkeeping
//
//  Created by Sven van der Heide on 17-03-16.
//  Copyright © 2016 Sven van der Heide. All rights reserved.
//

import Cocoa
import ObjectMapper

open class JournalEntryComponent: NSObject, Mappable {
    public var isDebet:Bool
    public var amount:Float
    public var balanceItem:BalanceItem
    public var journalEntry:JournalEntry?
    public var id:String
    
    
    public init(newIsDebet:Bool, newAmount:Float, newBalanceItem:BalanceItem){
        isDebet = newIsDebet
        amount = newAmount
        balanceItem = newBalanceItem
        self.id = UUID().uuidString
        super.init()
        
    }
    
    required public init?(map: Map) {
        isDebet = true
        amount = 0
        balanceItem = balanceItemList.first!
        self.id = NSUUID().uuidString
        super.init()
        mapping(map: map)
        print(self)
    }
    
    //should only be called from journalEntry
    func addToBalanceItem(){
        balanceItem.addJournalEntryComponent(self)
    }
 
    //should only be called from journalEntry
    func deleteFromBalanceItem(){
        if (!balanceItem.deleteJournalEntryComponent(self)){
            print("error deleting journal entry")
        }
    }
    
    public func mapping(map: Map) {
        isDebet    <- (map["IsDebit"], BooleanTransform())
        amount    <- map["Amount"]
        balanceItem    <- (map["BIID"], BalanceItemTransform())
        //journalEntry!.id    <- map["JEID"]
        id      <- map["ID"]
    }
    
}
public func splitDebitAndCreditJournalEntryComponents(_ components:[JournalEntryComponent])->[[JournalEntryComponent]]{
    let debitComponents = components.filter { (component) -> Bool in
        component.isDebet
    }
    let crebitComponents = components.filter { (component) -> Bool in
        !component.isDebet
    }
    
    return [debitComponents, crebitComponents]
}

