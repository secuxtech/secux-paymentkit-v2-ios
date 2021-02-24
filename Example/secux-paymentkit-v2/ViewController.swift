//
//  ViewController.swift
//  secux-paymentkit-v2
//
//  Created by maochuns on 05/06/2020.
//  Copyright (c) 2020 maochuns. All rights reserved.
//

import UIKit
import secux_paymentkit_v2

class ViewController: UIViewController {
    
    #if arch(i386) || arch(x86_64)
    #else
    
    private let accountManager = SecuXAccountManager()
    private let paymentManager = SecuXPaymentManager()
    private var theUserAccount : SecuXUserAccount?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let util = SecuXEncUtility()
        let encInfo = util.encryptInfoData(info: "{\"transactionId\" : \"805eefa0db020bf5\",\"memo\": \"test\"}", key: "JdVa0oOqQAr0ZMdtcTwHrQ==")
        print("encInfo \(String(describing: encInfo))")
        
        //theUserAccount = SecuXUserAccount(email: "maochuntest1@secuxtech.com", phone: "0975123456", password: "12345678")
        theUserAccount = SecuXUserAccount(email: "0932337867@bitsense.tw", phone: "0975123456", password: "hollygold093233")
        self.accountManager.setBaseServer(url: "https://pmsweb-sandbox.secuxtech.com")
        
        self.accountManager.setAdminAccount(name: "secux_register", password: "!secux_register@123")
        
        self.paymentManager.delegate = self
        DispatchQueue.global(qos: .default).async {
            //self.doAccountActions()
            self.doPaymentActions()
            
            //self.doRefundReillTest()
            //self.doEncryptPaymentDataTest()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Try account related functions
    func doAccountActions(){
        
        //Get all server supported coin and token
        
        let (getCoinTokenRet, coinTokenReplyData, coinTokenArray) = accountManager.getSupportedCoinTokenArray()
        //print("data: \(String(data: data!, encoding: String.Encoding.utf8) ?? "")")
        if getCoinTokenRet == SecuXRequestResult.SecuXRequestOK, let coinTokenArr = coinTokenArray, coinTokenArr.count > 0 {
            
            let (regret, retdata) = accountManager.registerUserAccount(userAccount: theUserAccount!, coinType: coinTokenArr[0].coin, token: coinTokenArr[0].token)
            if regret == SecuXRequestResult.SecuXRequestOK {
                print("register new account successfully!")
            }else{
                if let data = retdata{
                    print("Error: \(String(data: data, encoding: String.Encoding.utf8) ?? "")")
                }
            }
            
        }else{
            print("getSupportedCoinTokenArray failed")
            if let data = coinTokenReplyData{
                print("Error: \(String(data: data, encoding: String.Encoding.utf8) ?? "")")
            }
        }
        
        //Login test
        var (ret, data) = accountManager.loginUserAccount(userAccount: theUserAccount!)
        guard ret == SecuXRequestResult.SecuXRequestOK else{
            print("login failed!")
            if let data = data{
                print("Error: \(String(data: data, encoding: String.Encoding.utf8) ?? "")")
            }
            return
        }
        
        //(ret, data) = accountManager.changePassword(oldPwd: "12345678", newPwd: "123456")
        //(ret, data) = accountManager.changePassword(oldPwd: "123456", newPwd: "12345678")
        
        
        //Get all coin account
        (ret, data) = accountManager.getCoinAccountList(userAccount: theUserAccount!)
        
        guard ret == SecuXRequestResult.SecuXRequestOK else{
            print("get coin account failed")
            if let data = data{
                print("Error: \(String(data: data, encoding: String.Encoding.utf8) ?? "")")
            }
            return
        }
    
        /*
        let (ret, data) = accountManager.getAccountBalance(userAccount: theUserAccount, coinType: "DCT", token: "BEE")
        
        guard ret == SecuXRequestResult.SecuXRequestOK else{
            print("get balance failed")
            if let data = data{
                print("Error: \(String(data: data, encoding: String.Encoding.utf8) ?? "")")
            }
            return
        }
       
        if theUserAccount.coinAccountArray.count > 0 {
            let beeAcc = theUserAccount.coinAccountArray[0]
            
            if let tokenBal = beeAcc.tokenBalanceDict["BEE"]{
                print("\(tokenBal.theFormattedBalance)")
            }
        }
        */
        
        //print out balance
        for coinAcc in theUserAccount!.coinAccountArray{
            let tokenArr = coinAcc.tokenBalanceDict.keys
            for token in tokenArr{
                
                //Get balance for a specified coin and token account
                (ret, data) = accountManager.getAccountBalance(userAccount: theUserAccount!, coinType: coinAcc.coinType, token: token)
                
                guard ret == SecuXRequestResult.SecuXRequestOK else{
                    print("get \(coinAcc.coinType) \(token) balance failed")
                    if let data = data{
                        print("Error: \(String(data: data, encoding: String.Encoding.utf8) ?? "")")
                    }
                    continue
                }
               
                if let tokenBal = coinAcc.tokenBalanceDict["key"]{
                    print("\(coinAcc.coinType) \(token) \(tokenBal.theBalance) \(tokenBal.theFormattedBalance) \(tokenBal.theUsdBalance)")
                }
                
            }
        }
        
        
        
        
    
        /*
        //Transfer
        let (reqret, reqdata, transRet) = accountManager.doTransfer(coinType: "DCT", token: "SPC", feeSymbol: "SFC", amount: "1.2", receiver: "maochuntest7@secuxtech.com")
        guard reqret == SecuXRequestResult.SecuXRequestOK else{
            print("transfer failed!")
            if let reqdata = reqdata{
                print("Error: \(String(data: reqdata, encoding: String.Encoding.utf8) ?? "")")
            }
            return
        }
        
        print("Transfer result txID=\(transRet?.txID ?? "") url=\(transRet?.detailsUrl ?? "")")
        
        //Tranfer history
        var pageIdx = 0
        let pageItemCount = 20
        while (true){
        
            let (ret, transHisArr) = accountManager.getTransferHistory(coinType: "DCT", token: "SPC", page: pageIdx, count: pageItemCount)
            
            if ret != SecuXRequestResult.SecuXRequestOK{
                print("get tranfer history failed \(ret)")
                break;
            }
            
            var idx = 0
            for tranHis in transHisArr{
                print("\(idx) \(tranHis.token) \(tranHis.timestamp) \(tranHis.formattedAmount) \(tranHis.detailsUrl)")
                idx += 1
            }
            
            if transHisArr.count < pageItemCount{
                break
            }
            
            pageIdx += 1
        }
        */
    }
    
    //Try payment related functions
    func doPaymentActions(){
        
        var (ret, data) = accountManager.loginUserAccount(userAccount: theUserAccount!)
        guard ret == SecuXRequestResult.SecuXRequestOK else{
            print("login failed!")
            if let data = data{
                print("Error: \(String(data: data, encoding: String.Encoding.utf8) ?? "")")
            }
            return
        }
        
        //Get payment history
        print("get payment history")
        var pageIdx = 0
        let pageItemCount = 20
        while (true){
        
            let (ret, payHisArr) = paymentManager.getPaymentHistory(token: "", pageIdx: pageIdx, pageItemCount: pageItemCount)
            
            if ret != SecuXRequestResult.SecuXRequestOK{
                print("get payment history failed \(ret)")
                return
            }
            
            var idx = 0
            for payHis in payHisArr{
                print("\(idx) \(payHis.coinType) \(payHis.token) \(payHis.transactionTime) \(payHis.amount) \(payHis.detailsUrl)")
                idx += 1
            }
            
            if payHisArr.count < pageItemCount{
                break
            }
            
            pageIdx += 1
        }
        
        /*
        //Pay to store
        //let paymentInfo = "{\"amount\":\"1.5\", \"coinType\":\"DCT\", \"token\":\"SPC\",\"deviceIDhash\":\"f962639145992d7a710d33dcca503575eb85d759\"}"
        
        //let paymentInfo = "{\"amount\":\"2\", \"coinType\":\"DCT:SPC\",\"deviceIDhash\":\"592e41d67ee326f82fd6be518fd488d752f5a1b9\"}"
        
        //let paymentInfo = "{\"amount\":\"2\", \"coinType\":\"DCT:SPC\",\"deviceIDhash\":\"f962639145992d7a710d33dcca503575eb85d759\"}"
        
        
        
        let paymentInfo = "{\"amount\":\"2\", \"coinType\":\"DCT:SPC\",\"deviceIDhash\":\"b273e189b06b874969fd5a75cd3489dc03873c85\"}"
        
        (ret, data) = paymentManager.getPaymentInfo(paymentInfo: paymentInfo)
        if ret == SecuXRequestResult.SecuXRequestOK, let data = data{
            print("get payment info. done")
            guard let responseJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else{
                print("Invalid json response from server")
                return
            }
            
            guard let devIDHash = responseJson["deviceIDhash"] as? String else{
                print("Response has no hashed devID")
                return
            }
            
          
            let (reqRet, error, info) = paymentManager.getStoreInfo(devID: devIDHash)
            guard reqRet == SecuXRequestResult.SecuXRequestOK, let storeInfo = info else{
                    print("Get store information from server failed! \(error)")
                    return
            }
            
             
            print("Get store info. done! storename=\(storeInfo.name)")
            
            var payinfoDict = [String : String]()
            payinfoDict["amount"] = "12"
            payinfoDict["coinType"] = "DCT"
            payinfoDict["token"] = "SPC"
            payinfoDict["deviceID"] = storeInfo.devID
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: payinfoDict, options: []),
                let paymentInfo = String(data: jsonData, encoding: String.Encoding.utf8) else{
                    self.showMessage(title: "Invalid payment information", message: "Payment abort!")
                    return
            }
            self.paymentManager.doPaymentAsync(nonce: "1b2c3d4e", storeInfo: storeInfo.info, paymentInfo: paymentInfo)
            
    
        }else{
            print("get payment info. from server failed")
        }
        */
    
    }
    
    func doRefundReillTest(){
        let (ret, data) = accountManager.loginUserAccount(userAccount: theUserAccount!)
        guard ret == SecuXRequestResult.SecuXRequestOK else{
            print("login failed!")
            if let data = data{
                print("Error: \(String(data: data, encoding: String.Encoding.utf8) ?? "")")
            }
            return
        }
        
        let (refundRet, info) = self.paymentManager.doRefund(nonce:"1b2a3c4d", devID: "811c000009c5", devIDHash: "592e41d67ee326f82fd6be518fd488d752f5a1b9")
        print("refund result \(refundRet), \(info)")
    }
    
    func doEncryptPaymentDataTest(){
        let (ret, data) = accountManager.loginUserAccount(userAccount: theUserAccount!)
        guard ret == SecuXRequestResult.SecuXRequestOK else{
            print("login failed!")
            if let data = data{
                print("Error: \(String(data: data, encoding: String.Encoding.utf8) ?? "")")
            }
            return
        }
        
        let (encret, enctxt) = paymentManager.doActivity(userID: theUserAccount!.name, devID: "811c000009c5", coin: "$", token: "MQ03T",
                                                         transID: "test123456", amount: "1", nonce: "abcdef", type: "payment")
        print("doEncryptPaymentDataTest result \(encret), \(enctxt)")
    }
    
    func showMessage(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    #endif
}


#if arch(i386) || arch(x86_64)
#else
//MARK: SecuXPaymentManagerDelegate implementation
extension ViewController: SecuXPaymentManagerDelegate{
    
    //Called when payment is completed. Returns payment result and error message.
    func paymentDone(ret: Bool, transactionCode: String, errorMsg: String) {
        print("paymentDone \(ret) \(transactionCode) \(errorMsg)")
        
        if ret{
            
            showMessage(title: "Payment success!", message: "")
            let (ret, payhis) = self.paymentManager.getPaymentHistory(token:"SPC", transactionCode: transactionCode)
            if ret == SecuXRequestResult.SecuXRequestOK, let his = payhis{
                print("payment detail: \(his.amount) \(his.storeName) \(his.storeID) \(his.storeTel) \(his.storeAddress)")
            }
        
        }else{
            showMessage(title: "Payment fail!", message:errorMsg)
        }
    }
    
    //Called when payment status is changed. Payment status are: "Device connecting...", "DCT transferring..." and "Device verifying..."
    func updatePaymentStatus(status: String) {
        print("updatePaymentStatus \(status)")
    }
    
}

#endif
