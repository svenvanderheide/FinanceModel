//
//  DBService.swift
//  FinanceModel
//
//  Created by Sven van der Heide on 22-11-16.
//  Copyright © 2016 Sven van der Heide. All rights reserved.
//

import Foundation
import ObjectMapper

public protocol DBService{
    func saveBalanceItem()
    func deleteBalanceItem()
    static func getBalanceItem()
}

public protocol MappableDBSender:DBSender, Mappable{
    
}

public protocol DBSender{
    var DBService:DBService?{get}
    func getWriteStatemnt()->String
}

open class SQLService:DBService{
    let localUrl = "http://127.0.0.1:8181/";
    let serverUrl = "http://ec2-52-57-194-158.eu-central-1.compute.amazonaws.com:8181";
    var dbSender: MappableDBSender
    var typeName:String
    init(typeName: String, dbSender: MappableDBSender) {
        self.typeName = typeName
        self.dbSender = dbSender
    }
    public func saveBalanceItem() {
        let request = NSMutableURLRequest(url: URL(string: "http://127.0.0.1:8181/\(typeName)")!)
        let content = dbSender.toJSONString(prettyPrint: false);//"hoi"//Mapper().toJSONString(DBSender, prettyPrint: false)
        let entry = "content=[\(content)]"
        request.httpMethod = "POST"
        let postString = entry
        request.httpBody = postString.data(using: String.Encoding.utf8)
        print("simple test request",request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
        
            if error != nil {
                print("error=\(error)")
                return
            }
        
            print("response = \(response)")
        
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString)")
            
        }
        task.resume()
    }
    public func deleteBalanceItem() {
        print("hoi")
    }
    
    public static func getBalanceItem() {
    }
    
}
