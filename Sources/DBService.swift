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
    func saveFinanceObject()
    func deleteFinanceObject()
    static func getFinanceObject(financeType:String)
}

public protocol MappableDBSender:DBSender, Mappable{
    
}

public protocol DBSender{
    var DBService:DBService?{get}
    func getWriteStatemnt()->[String]
}

open class SQLService:DBService{
    static let localUrl = "http://127.0.0.1:8181/";
    static let serverUrl = "http://ec2-52-57-194-158.eu-central-1.compute.amazonaws.com:8181";
    var dbSender: MappableDBSender
    var typeName:String
    init(typeName: String, dbSender: MappableDBSender) {
        self.typeName = typeName
        self.dbSender = dbSender
    }
    public func saveFinanceObject() {
        let request = NSMutableURLRequest(url: URL(string: "\(SQLService.localUrl)financeObject")!)
        let content = dbSender.toJSONString(prettyPrint: false)!;//"hoi"//Mapper().toJSONString(DBSender, prettyPrint: false)
        
        let entry = "\(self.typeName)=[\(content)]"
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
    public func deleteFinanceObject() {
        print("hoi")
    }
    
    public static func getFinanceObject(financeType:String) {
        let urlRequest = NSMutableURLRequest(url: URL(string: "\(localUrl)financeObject/\(financeType)")!) //getBalanceItems.php"
        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode
            
            if (statusCode == 200) {
                print("Everyone is fine, file downloaded successfully.",data)
                
                do{
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options:[])
                    print("json",json)
                
                    if let json = json as? [String:[[String: AnyObject]]]{
                        if let bJson = json["BalanceItem"]{
                        for entry in bJson {
                                let bi = BalanceItem(map: Map(mappingType: .fromJSON , JSON: entry))
                            }
                            //let je = JournalEntry(map: Map(mappingType: .fromJSON , JSON: entry))
                            //print("sven hoi",  bi?.isDebet)
                        }
                    }

                }catch {
                    print("Error with Json: \(error)")
                }
                
            }
        }
        task.resume()
    }
    
}
