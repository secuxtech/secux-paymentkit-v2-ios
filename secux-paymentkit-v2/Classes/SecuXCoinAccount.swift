//
//  SecuXCoinAccount.swift
//  secux-paymentkit
//
//  Created by Maochun Sun on 2020/3/6.
//

import Foundation

public class SecuXCoinAccount{
    public var coinType = "";
    public var accountName = ""
    public var tokenBalanceDict = [String : SecuXCoinTokenBalance]()
    
    init(type:String, name:String, tokenBalDict:[String:SecuXCoinTokenBalance]) {
        coinType = type
        accountName = name
        tokenBalanceDict = tokenBalDict
    }
    
    public func updateTokenBalance(token:String, tokenBal:SecuXCoinTokenBalance)->Bool{
        
        guard let oldTokenBal = tokenBalanceDict[token] else{
            return false;
        }
        
        oldTokenBal.copyValueFrom(tokenBalance: tokenBal)
        
        return true;
    }
    
    public func getTokenBalance(token:String)->SecuXCoinTokenBalance?{
        return tokenBalanceDict[token]
    }
}
