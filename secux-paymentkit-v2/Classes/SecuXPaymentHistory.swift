//
//  SecuXPaymentHistory.swift
//  secux-paymentkit
//
//  Created by Maochun Sun on 2020/3/6.
//

import Foundation

public class SecuXPaymentHistory{
    
    public var theID : Int = 0
    
    public var storeID : Int = 0
    public var storeName : String = ""
    public var storeTel : String = ""
    public var storeAddress : String = ""
    
    public var userAccountName : String = ""
    public var transactionCode : String = ""
    public var transactionType : String = ""
    
    public var payPlatorm : String = ""
    public var payChannel : String = ""
    
    public var coinType : String = ""
    public var token : String = ""
    public var amount : String = ""
    
    public var transactionStatus : String = ""
    public var transactionTime : String = ""
    
    public var remark : String = ""
    public var detailsUrl : String = ""
    
    init() {
        
    }
    
    init?(hisData: Data) {
        do {
            if let hisJson = try JSONSerialization.jsonObject(with: hisData, options: []) as? [String: Any]{
                
                self.theID = hisJson["id"] as! Int
                self.storeID = hisJson["storeID"] as! Int
                self.storeName = hisJson["storeName"] as! String
                self.storeTel = hisJson["storeTel"] as! String
                self.storeAddress = hisJson["storeAddress"] as! String
                self.userAccountName = hisJson["account"] as! String
                self.transactionCode = hisJson["transactionCode"] as! String
                self.transactionType = hisJson["transactionType"] as! String
                self.payPlatorm = hisJson["payPlatform"] as! String
                self.payChannel = hisJson["payChannel"] as! String
                self.coinType = hisJson["coinType"] as! String
                self.token = hisJson["symbol"] as! String
                self.amount = hisJson["amount"] as! String
                self.transactionStatus = hisJson["transactionStatus"] as! String
                self.transactionTime = hisJson["transactionTime"] as! String
                self.remark = hisJson["remark"] as! String
                self.detailsUrl = hisJson["detailsUrl"] as! String
            }else{
                return nil
            }
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    init?(hisJson: [String : Any]) {
        
        guard let id = hisJson["id"] as? Int,
            let userAccountName = hisJson["account"] as? String,
            let transactionCode = hisJson["transactionCode"] as? String,
            let transactionType = hisJson["transactionType"] as? String,
            let payPlatorm = hisJson["payPlatform"] as? String,
            let payChannel = hisJson["payChannel"] as? String,
            let coinType = hisJson["coinType"] as? String,
            let token = hisJson["symbol"] as? String,
            let amount = hisJson["amount"] as? Double,
            let transactionStatus = hisJson["transactionStatus"] as? String,
            let transactionTime = hisJson["transactionTime"] as? String,
            let remark = hisJson["remark"] as? String else {
            //let detailsUrl = hisJson["detailsUrl"] as? String else{
                return nil
        }
        
        let detailsUrl = hisJson["detailsUrl"] as? String
        let storeID = hisJson["storeID"] as? Int
        let storeName = hisJson["storeName"] as? String
        let storeTel = hisJson["storeTel"] as? String
        let storeAddress = hisJson["storeAddress"] as? String
        
        
        self.theID = id
        self.storeID = storeID ?? 0
        self.storeName = storeName ?? ""
        self.storeTel = storeTel ?? ""
        self.storeAddress = storeAddress ?? ""
        self.userAccountName = userAccountName
        self.transactionCode = transactionCode
        self.transactionType = transactionType
        self.payPlatorm = payPlatorm
        self.payChannel = payChannel
        self.coinType = coinType
        self.token = token
        self.amount = Decimal(amount).description
        self.transactionStatus = transactionStatus
        self.transactionTime = transactionTime
        self.remark = remark
        self.detailsUrl = detailsUrl ?? ""
        
    }
    
}
