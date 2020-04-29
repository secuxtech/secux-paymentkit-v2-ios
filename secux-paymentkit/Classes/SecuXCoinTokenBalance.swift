//
//  SecuXCoinTokenBalance.swift
//  secux-paymentkit
//
//  Created by Maochun Sun on 2020/3/6.
//

import Foundation

public class SecuXCoinTokenBalance{
    
    public var theBalance : Decimal = 0;
    public var theFormattedBalance : Decimal = 0;
    public var theUsdBalance : Decimal = 0;
    
    init(balance:Decimal, formattedBalance:Decimal, usdBalance:Decimal){
        theBalance = balance
        theFormattedBalance = formattedBalance
        theUsdBalance = usdBalance
    }
    
    func copyValueFrom(tokenBalance:SecuXCoinTokenBalance){
        theBalance = tokenBalance.theBalance
        theFormattedBalance = tokenBalance.theFormattedBalance
        theUsdBalance = tokenBalance.theUsdBalance
    }
    
}
