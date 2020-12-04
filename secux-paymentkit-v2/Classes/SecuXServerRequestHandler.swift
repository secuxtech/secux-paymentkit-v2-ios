//
//  SecuXServerRequestHandler.swift
//  SecuXWallet
//
//  Created by Maochun Sun on 2019/12/2.
//  Copyright © 2019 Maochun Sun. All rights reserved.
//

import Foundation


class SecuXServerRequestHandler: RestRequestHandler {
    

    static var baseURL = "https://pmsweb-sandbox.secuxtech.com" //"https://pmsweb-test.secux.io"  //"https://pmsweb-sandbox.secuxtech.com" //"https://pmsweb-test.secux.io"
    static var adminLoginUrl = baseURL + "/api/Admin/Login"
    static var registerUrl = baseURL + "/api/Consumer/Register"
    static var userLoginUrl = baseURL + "/api/Consumer/Login"
    static var changePwdUrl = baseURL + "/api/Consumer/ChangePassword"
    static var transferUrl = baseURL + "/api/Consumer/Transfer"
    static var balanceUrl = baseURL + "/api/Consumer/GetAccountBalance"
    static var balanceListUrl = baseURL + "/api/Consumer/GetAccountBalanceList"
    static var paymentUrl = baseURL + "/api/Consumer/Payment"
    static var paymentHistoryUrl = baseURL + "/api/Consumer/GetPaymentHistory"
    static var getStoreUrl = baseURL + "/api/Terminal/GetStore"
    static var transferHistoryUrl = baseURL + "/api/Consumer/GetTxHistory"
    static var getDeviceInfoUrl = baseURL + "/api/Terminal/GetDeviceInfo"
    static var getSupportedSymbol = baseURL + "/api/Terminal/GetSupportedSymbol"
    static var getChainAccountList = baseURL + "/api/Consumer/GetChainAccountList"
    static var accountOperationUrl = baseURL + "/api/Consumer/BindingChainAccount"
    static var refundUrl = baseURL + "/api/Consumer/Refund";
    static var refillUrl = baseURL + "/api/Consumer/Refill";
    static var encryptPaymentDataUrl = baseURL + "/api/B2B/ProduceCipher";
    
    static var getPaymentUrlUrl = baseURL + "/api/Consumer/GetFiatPaymentUrl"
    static var checkPaymentStatus = baseURL + "/api/Consumer/CheckFiatPaymentStatus"
    
    private static var theToken = ""
    
    static func setServerURL(url:String){
        baseURL = url
        adminLoginUrl = baseURL + "/api/Admin/Login"
        registerUrl = baseURL + "/api/Consumer/Register"
        userLoginUrl = baseURL + "/api/Consumer/Login"
        changePwdUrl = baseURL + "/api/Consumer/ChangePassword"
        transferUrl = baseURL + "/api/Consumer/Transfer"
        balanceUrl = baseURL + "/api/Consumer/GetAccountBalance"
        balanceListUrl = baseURL + "/api/Consumer/GetAccountBalanceList"
        paymentUrl = baseURL + "/api/Consumer/Payment"
        paymentHistoryUrl = baseURL + "/api/Consumer/GetPaymentHistory"
        getStoreUrl = baseURL + "/api/Terminal/GetStore"
        transferHistoryUrl = baseURL + "/api/Consumer/GetTxHistory"
        getDeviceInfoUrl = baseURL + "/api/Terminal/GetDeviceInfo"
        getSupportedSymbol = baseURL + "/api/Terminal/GetSupportedSymbol"
        getChainAccountList = baseURL + "/api/Consumer/GetChainAccountList"
        accountOperationUrl = baseURL + "/api/Consumer/BindingChainAccount"
        refundUrl = baseURL + "/api/Consumer/Refund"
        refillUrl = baseURL + "/api/Consumer/Refill"
        encryptPaymentDataUrl = baseURL + "/api/B2B/ProduceCipher"
        
        getPaymentUrlUrl = baseURL + "/api/Consumer/GetFiatPaymentUrl"
        checkPaymentStatus = baseURL + "/api/Consumer/CheckFiatPaymentStatus"
    }
    
    private static var adminAccountName = ""
    private static var adminAccountPassword = ""
    
    func setAdminAccount(name:String, password:String){
        SecuXServerRequestHandler.adminAccountName = name
        SecuXServerRequestHandler.adminAccountPassword = password
    }
    
    
    func getAdminToken() -> String?{
        logw("getAdminToken")
        
        var adminPwd = ""
        var adminName = ""
        if SecuXServerRequestHandler.adminAccountName.count > 0, SecuXServerRequestHandler.adminAccountPassword.count > 0{
            adminName = SecuXServerRequestHandler.adminAccountName
            adminPwd = SecuXServerRequestHandler.adminAccountPassword
        }else{
            
            /*
            adminName = "secux_register"
            adminPwd = "!secux_register@123"
            if SecuXServerRequestHandler.baseURL.caseInsensitiveCompare("https://pmsweb.secuxtech.com") == .orderedSame{
                adminPwd = "168!Secux@168"
            }
            */
            
            return nil
        }
        
        let param = ["account": adminName, "password":adminPwd]
        let (ret, data) = self.postRequestSync(urlstr: SecuXServerRequestHandler.adminLoginUrl, param: param)
        if ret == SecuXRequestResult.SecuXRequestOK, let tokenData = data{
            
            guard let tmp = ((try? JSONSerialization.jsonObject(with: tokenData, options: []) as? [String: Any]) as [String : Any]??),
                  let json = tmp else{
                return nil
            }
            
            if let token = json["token"] as? String {
                return token
            }
            
        }
        return nil;
    }
    
    func userRegister(userAccount: SecuXUserAccount, coinType: String, token: String) -> (SecuXRequestResult, Data?){
        logw("userRegister")
        guard let bearerToken = getAdminToken() else{
            return (SecuXRequestResult.SecuXRequestNoToken, nil);
        }
        
        let param = ["account": userAccount.name, "password": userAccount.password, "email":userAccount.email, "alias":userAccount.alias,
                     "tel":userAccount.phone, "coinType": coinType, "symbol": token,"optional":"{}"] as [String : Any];
        return self.postRequestSync(urlstr: SecuXServerRequestHandler.registerUrl, param: param, token: bearerToken, withTimeout: 30000);
    }
    
    func userLogin(account: String, password: String) -> (SecuXRequestResult, Data?){
        logw("userLogin")
        let param = ["account": account, "password":password]
        let (ret, data) = self.postRequestSync(urlstr: SecuXServerRequestHandler.userLoginUrl, param: param)
        
        guard ret == SecuXRequestResult.SecuXRequestOK, let replyData = data else{
            
            return (SecuXRequestResult.SecuXRequestNoToken, nil)
        }
        
        guard let tmp = ((try? JSONSerialization.jsonObject(with: replyData, options: []) as? [String: Any]) as [String : Any]??),
              let json = tmp else{
            return (SecuXRequestResult.SecuXRequestFailed, "Invalid response json".data(using: String.Encoding.utf8))
        }
        
        guard let token = json["token"] as? String else{
            return (SecuXRequestResult.SecuXRequestFailed, "Response has no token".data(using: String.Encoding.utf8))
        }
        
        
        SecuXServerRequestHandler.theToken = token
        return (ret, data)
    }
    
    func merchantLogin(account: String, password: String) -> (SecuXRequestResult, Data?){
        logw("merchantLogin")
        let param = ["account": account, "password":password]
        let (ret, data) = self.postRequestSync(urlstr: SecuXServerRequestHandler.adminLoginUrl, param: param)
        
        guard ret == SecuXRequestResult.SecuXRequestOK, let replyData = data else{
            
            return (SecuXRequestResult.SecuXRequestNoToken, nil)
        }
        
        guard let tmp = ((try? JSONSerialization.jsonObject(with: replyData, options: []) as? [String: Any]) as [String : Any]??),
              let json = tmp else{
            return (SecuXRequestResult.SecuXRequestFailed, "Invalid response json".data(using: String.Encoding.utf8))
        }
        
        guard let token = json["token"] as? String else{
            return (SecuXRequestResult.SecuXRequestFailed, "Response has no token".data(using: String.Encoding.utf8))
        }
        
        
        SecuXServerRequestHandler.theToken = token
        return (ret, data)
    }
    
    func getSupportedCoinTokens()  -> (SecuXRequestResult, Data?){
        logw("getSupportedToken")
        
        guard let bearerToken = getAdminToken() else{
            return (SecuXRequestResult.SecuXRequestNoToken, nil);
        }

        return self.postRequestSync(urlstr: SecuXServerRequestHandler.getSupportedSymbol, param: nil, token: bearerToken)
    }
    
    func getChainAccountList() -> (SecuXRequestResult, Data?){
        logw("getChainAccountList")

        if SecuXServerRequestHandler.theToken.count == 0{
            logw("no token")
            return (SecuXRequestResult.SecuXRequestNoToken, nil)
        }
       
        return self.postRequestSync(urlstr: SecuXServerRequestHandler.getChainAccountList, param: [String:String](), token: SecuXServerRequestHandler.theToken)
       
    }
    
    func changePassword(oldPwd: String, newPwd: String) -> (SecuXRequestResult, Data?){
        logw("changePassword")
        
        if SecuXServerRequestHandler.theToken.count == 0{
            logw("no token")
            return (SecuXRequestResult.SecuXRequestNoToken, nil)
        }
        
        let param = ["password":oldPwd, "newPassword":newPwd]
        let url = SecuXServerRequestHandler.changePwdUrl
        
        return self.postRequestSync(urlstr: url, param: param, token:SecuXServerRequestHandler.theToken)
    }
    
    func getAccountBalance(coinType: String = "", token: String = "") ->(SecuXRequestResult, Data?){
        logw("getAccountBalance")
        
        if SecuXServerRequestHandler.theToken.count == 0{
            logw("no token")
            return (SecuXRequestResult.SecuXRequestNoToken, nil)
        }
        
        var param : [String : Any]?
        var url = SecuXServerRequestHandler.balanceListUrl
        if coinType.count > 0, token.count > 0{
            param = ["coinType":coinType, "symbol":token]
            url = SecuXServerRequestHandler.balanceUrl
        }
        return self.postRequestSync(urlstr: url, param: param, token:SecuXServerRequestHandler.theToken)
    }
    
    func getStoreInfo(devID: String)->(SecuXRequestResult, Data?){
        logw("getStoreInfo")
        
        if SecuXServerRequestHandler.theToken.count == 0{
            logw("no token")
            return (SecuXRequestResult.SecuXRequestNoToken, nil)
        }
        
        let param = ["deviceIDhash":devID]
        return self.postRequestSync(urlstr: SecuXServerRequestHandler.getStoreUrl, param: param, token: SecuXServerRequestHandler.theToken)
    }
    
    func getDeviceInfo(paymentInfo: String)->(SecuXRequestResult, Data?){
        logw("getDeviceInfo")
        
        if SecuXServerRequestHandler.theToken.count == 0{
            logw("no token")
            return (SecuXRequestResult.SecuXRequestNoToken, nil)
        }
        
        if let data = paymentInfo.data(using: .utf8) {
            do {
                if let param = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
                    return self.postRequestSync(urlstr: SecuXServerRequestHandler.getDeviceInfoUrl, param: param, token: SecuXServerRequestHandler.theToken)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return (SecuXRequestResult.SecuXRequestInvalidParameter, nil)
    }
    
    func doPayment(payInfo: PaymentInfo)->(SecuXRequestResult, Data?){
        logw("doPayment")
        
        if SecuXServerRequestHandler.theToken.count == 0{
            logw("no token")
            return (SecuXRequestResult.SecuXRequestNoToken, nil)
        }
        
        let secondsFromGMT = TimeZone.current.secondsFromGMT()
        let param = ["ivKey":payInfo.ivKey,
                     "memo":"",
                     "symbol":payInfo.token,
                     "amount":payInfo.amount,
                     "coinType":payInfo.coinType,
                     "receiver":payInfo.deviceID,
                     "timeZone":"\(secondsFromGMT)"]
        
        return self.postRequestSync(urlstr: SecuXServerRequestHandler.paymentUrl, param: param, token: SecuXServerRequestHandler.theToken)
    }
    
    func doTransfer(coinType: String, token: String, feesymbol: String, receiver: String, amount: String)->(SecuXRequestResult, Data?){
        logw("doTransfer")
        
        if SecuXServerRequestHandler.theToken.count == 0{
            logw("no token")
            return (SecuXRequestResult.SecuXRequestNoToken, nil)
        }
        
        let param = ["coinType":coinType, "symbol":token, "feeSymbol":feesymbol, "receiver":receiver, "amount":amount]
        return self.postRequestSync(urlstr: SecuXServerRequestHandler.transferUrl, param: param, token: SecuXServerRequestHandler.theToken)
    }
    
    func getPaymentHistory(token: String, pageIdx: Int, pageItemCount: Int)->(SecuXRequestResult, Data?){
        logw("getPaymentHistory")
        
        if SecuXServerRequestHandler.theToken.count == 0{
            logw("no token")
            return (SecuXRequestResult.SecuXRequestNoToken, nil)
        }
        
        let subparam = ["offset":pageIdx, "limit":pageItemCount, "sort": "transactionTime", "order": "descending"] as [String : Any]
        let param = ["keyword": "",
                    "startTime": "",
                    "endTime": "",
                    "payChannel": "",
                    "symbol": "",
                    "transactionStatus": "",
                    "params":subparam] as [String : Any]
        return self.postRequestSync(urlstr: SecuXServerRequestHandler.paymentHistoryUrl, param: param, token: SecuXServerRequestHandler.theToken)
    }
    
    
    func getPaymentHistory(token: String, transactionCode: String)->(SecuXRequestResult, Data?){
        logw("getPaymentHistory")
        if SecuXServerRequestHandler.theToken.count == 0{
            logw("no token")
            return (SecuXRequestResult.SecuXRequestNoToken, nil)
        }
        
        //let param = ["symbol":token, "page":1, "count":10, "columnName":"", "sorting":"", "transactionCode":transactionCode] as [String : Any]
        
        let subparam = ["offset":0, "limit":10, "sort": "transactionTime", "order": "descending"] as [String : Any]
        let param = ["keyword": transactionCode,
                    "startTime": "",
                    "endTime": "",
                    "payChannel": "",
                    "symbol": token,
                    "transactionStatus": "",
                    "params":subparam] as [String : Any]
        
        return self.postRequestSync(urlstr: SecuXServerRequestHandler.paymentHistoryUrl, param: param, token: SecuXServerRequestHandler.theToken)
    }
    
    func getTransferHistory(cointType: String, token: String, page: Int, pageItemCount: Int)->(SecuXRequestResult, Data?){
        logw("getTransferHistory")
        
        if SecuXServerRequestHandler.theToken.count == 0{
            logw("no token")
            return (SecuXRequestResult.SecuXRequestNoToken, nil)
        }
        
        let param = ["coinType": cointType, "symbol": token, "page":page, "count":pageItemCount] as [String : Any]
        return self.postRequestSync(urlstr: SecuXServerRequestHandler.transferHistoryUrl, param: param, token: SecuXServerRequestHandler.theToken)
    }
    
    func accountOperation(coinType:String, accountName:String, desc:String, type:String) -> (SecuXRequestResult, Data?){
        logw("accountOperation \(type)")
        
        if SecuXServerRequestHandler.theToken.count == 0{
            logw("no token")
            return (SecuXRequestResult.SecuXRequestNoToken, nil)
        }
        
        let param = ["coinType": coinType, "account": accountName, "desc":desc, "actionType":type] as [String : Any]
        return self.postRequestSync(urlstr: SecuXServerRequestHandler.accountOperationUrl, param: param, token: SecuXServerRequestHandler.theToken)
    }
    
    func refund(devIDHash:String, ivKey:String, dataHash:String) -> (SecuXRequestResult, Data?){
        if SecuXServerRequestHandler.theToken.count == 0{
            logw("no token")
            return (SecuXRequestResult.SecuXRequestNoToken, nil)
        }
        
        let secondsFromGMT = TimeZone.current.secondsFromGMT()
        let param = ["deviceIDhash": devIDHash,
                     "ivKey": ivKey,
                     "hashTx":dataHash,
                     "timeZone":"\(secondsFromGMT)"] as [String : Any]
        return self.postRequestSync(urlstr: SecuXServerRequestHandler.refundUrl, param: param, token: SecuXServerRequestHandler.theToken)
    }
    
    func refill(devIDHash:String, ivKey:String, dataHash:String) -> (SecuXRequestResult, Data?){
        if SecuXServerRequestHandler.theToken.count == 0{
            logw("no token")
            return (SecuXRequestResult.SecuXRequestNoToken, nil)
        }
        
        let secondsFromGMT = TimeZone.current.secondsFromGMT()
        let param = ["deviceIDhash": devIDHash,
                     "ivKey": ivKey,
                     "hashTx":dataHash,
                     "timeZone":"\(secondsFromGMT)"] as [String : Any]
        return self.postRequestSync(urlstr: SecuXServerRequestHandler.refillUrl, param: param, token: SecuXServerRequestHandler.theToken)
    }
    
    func encryptPaymentData(sender:String, devID:String, ivKey:String, coin:String, token:String, transID:String, amount:String, memo:String) -> (SecuXRequestResult, Data?){
        if SecuXServerRequestHandler.theToken.count == 0{
            logw("no token")
            return (SecuXRequestResult.SecuXRequestNoToken, "no token".data(using: .utf8))
        }
        
        let param = ["ivKey": ivKey,
                     "coinType": coin,
                     "symbol":token,
                     "sender":sender,
                     "deviceId":devID,
                     "transactionId":transID,
                     "amount":amount,
                     "memo":memo] as [String : String]
        
        return self.postRequestSync(urlstr: SecuXServerRequestHandler.encryptPaymentDataUrl, param: param, token: SecuXServerRequestHandler.theToken)
    }
    
    func getPaymentUrl(payChannel:String, devID:String, amount:String, productName:String ) -> (SecuXRequestResult, Data?){
        print("getPaymentUrl")
        if SecuXServerRequestHandler.theToken.count == 0{
            logw("no token")
            return (SecuXRequestResult.SecuXRequestNoToken, "no token".data(using: .utf8))
        }
        
        let secondsFromGMT = TimeZone.current.secondsFromGMT()
        let param = ["payChannel": payChannel,
                     "amount": amount,
                     "productName":productName,
                     "deviceId":devID,
                     "timeZone":"\(secondsFromGMT)"] as [String : String]
        
        return self.postRequestSync(urlstr: SecuXServerRequestHandler.getPaymentUrlUrl, param: param, token: SecuXServerRequestHandler.theToken)
        
    }
    
    func checkThirdPartyPaymentStatus(payChannel:String, orderID:String, devID:String, ivKey:String) -> (SecuXRequestResult, Data?){
        print("checkPaymentStatus")
        if SecuXServerRequestHandler.theToken.count == 0{
            logw("no token")
            return (SecuXRequestResult.SecuXRequestNoToken, "no token".data(using: .utf8))
        }
        
        let secondsFromGMT = TimeZone.current.secondsFromGMT()
        let param = ["ivKey":ivKey,
                     "payChannel": payChannel,
                     "orderId": orderID,
                     "deviceId":devID,
                     "timeZone":"\(secondsFromGMT)"] as [String : String]
        
        return self.postRequestSync(urlstr: SecuXServerRequestHandler.checkPaymentStatus, param: param, token: SecuXServerRequestHandler.theToken)
    }
}
