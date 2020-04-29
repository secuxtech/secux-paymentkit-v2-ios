//
//  SecuXTransferHistory.swift
//  secux-paymentkit
//
//  Created by Maochun Sun on 2020/3/6.
//

import Foundation

public class SecuXTransferHistory{
    
    public var txHash = ""
    public var address = ""
    public var txType = ""
    public var amount = ""
    public var token = ""
    public var feeToken = ""
    public var formattedAmount = ""
    public var usdAmount = ""
    public var timestamp = ""
    public var detailsUrl = ""
    
    init() {
        
    }
    
    init(hisData:Data){
        do {
            if let hisJson = try JSONSerialization.jsonObject(with: hisData, options: []) as? [String: Any]{
                
                self.txHash = hisJson["txHash"] as! String
                self.address = hisJson["address"] as! String
                self.txType = hisJson["tx_type"] as! String
                self.token = hisJson["amount_symbol"] as! String
                self.amount = hisJson["amount"] as! String
                self.feeToken = hisJson["fee_symbol"] as! String
                self.formattedAmount = hisJson["formatted_amount"] as! String
                self.usdAmount = hisJson["amount_usd"] as! String
                self.timestamp = hisJson["timestamp"] as! String
                self.detailsUrl = hisJson["detailsUrl"] as! String
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    init(hisJson:[String:Any]){
        self.txHash = hisJson["txHash"] as! String
        self.address = hisJson["address"] as! String
        self.txType = hisJson["tx_type"] as! String
        self.token = hisJson["amount_symbol"] as! String
        self.feeToken = hisJson["fee_symbol"] as! String
        self.timestamp = hisJson["timestamp"] as! String
        
        if let url = hisJson["detailsUrl"] as? String{
            self.detailsUrl = url
        }
        
        let amountDouble = hisJson["amount"] as! Double
        let formattedAmountDouble = hisJson["formatted_amount"] as! Double
        let usdAmountDouble = hisJson["amount_usd"] as! Double
        
        self.amount = String(amountDouble)
        self.formattedAmount = String(formattedAmountDouble)
        self.usdAmount = String(usdAmountDouble)
    }
    
}
