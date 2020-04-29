//
//  SecuXUserAccount.swift
//  secux-paymentkit
//
//  Created by Maochun Sun on 2020/3/6.
//

import Foundation

public class SecuXUserAccount{
    
    public var name = ""
    public var password = ""
    public var email = ""
    public var phone = ""
    public var alias = ""
    public var type = ""
    
    public var coinAccountArray = [SecuXCoinAccount]()
    
    public init() {
    }

    public init(email:String, phone:String, password:String){
        self.name = email
        self.password = password
        self.email = email
        
        if let separatorIdx = email.firstIndex(of: "@"){
            self.alias = String(email[..<separatorIdx])
        }else{
            self.alias = email
        }
        
        self.phone = phone
    }
    
    public init(email:String, password:String){
        self.name = email
        self.password = password
        self.email = email
        
        if let separatorIdx = email.firstIndex(of: "@"){
            self.alias = String(email[..<separatorIdx])
        }else{
            self.alias = email
        }
        
     
    }
    
    public func getCoinAccount(coinType:String) -> [SecuXCoinAccount]{
        
        var accountArray = [SecuXCoinAccount]()
        for account in coinAccountArray{
            if account.coinType == coinType{
                accountArray.append(account)
            }
        }
        return accountArray
    }
    
    public func addCoinAccount(coinAcc:SecuXCoinAccount){
        self.coinAccountArray.append(coinAcc)
    }
    
    public func removeAllCoinAccount(){
        self.coinAccountArray.removeAll()
    }
    
    public func supportToken(coin:String, token: String) -> Bool {
        for acc in self.coinAccountArray{
            
            if acc.coinType == coin, let _ = acc.getTokenBalance(token: token){
                return true
            }
        }
        
        return false
    }
    
}
