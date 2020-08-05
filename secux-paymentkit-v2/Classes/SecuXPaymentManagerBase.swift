//
//  PaymentHandler.swift
//  SecuXPaymentKit
//
//  Created by Maochun Sun on 2020/1/16.
//  Copyright © 2020 SecuX. All rights reserved.
//

import Foundation
//import SPManager
import secux_paymentdevicekit
import CoreNFC


extension String {


    var hexData: Data? {
        var data = Data(capacity: self.count / 2)

        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }

        guard data.count > 0 else { return nil }

        return data
    }

}


open class SecuXPaymentManagerBase{
    
    let secXSvrReqHandler = SecuXServerRequestHandler()
    let paymentPeripheralManager = SecuXPaymentPeripheralManager.init(scanTimeout: 5, connTimeout: 30, checkRSSI: -80)
    
    open var delegate: SecuXPaymentManagerDelegate?

    
    internal func sendRefundRefillInfoToDevice(dataToDev:Data) -> (SecuXRequestResult, String){
        do{
            let json  = try JSONSerialization.jsonObject(with: dataToDev, options: []) as! [String : Any]
            print("sendInfoToDevice recv \(json)  \n--------")
            
            if let statusCode = json["statusCode"] as? Int{
                if statusCode != 200{
                    let statusDesc = json["statusDesc"] as? String ?? ""
                    return (SecuXRequestResult.SecuXRequestFailed, "Invalid status code \(statusCode) from server! \(statusDesc)")
                }
            }
            
            if let machineControlParams = json["machineControlParam"] as? [String : Any],
                let encryptedStr = json["encryptedTransaction"] as? String,
                let transCode = json["transactionCode"] as? String,
                let encrypted = Data(base64Encoded: encryptedStr){
                
            
                logw("AccountPaymentViewModel doPaymentVerification")
               
                
                let (ret, errorMsg) = self.paymentPeripheralManager.doPaymentVerification(encPaymentData: encrypted, machineControlParams: machineControlParams)
                if ret == .OprationSuccess{
                    return (SecuXRequestResult.SecuXRequestOK, transCode)
                }else{
                    return (SecuXRequestResult.SecuXRequestFailed, errorMsg)
                }
              
                
            }else{
                
                return (SecuXRequestResult.SecuXRequestFailed, "Invalid data reply from server")
                
            }
            
        }catch{
            print("doPayment error: " + error.localizedDescription)
            
            return (SecuXRequestResult.SecuXRequestFailed, "Parsing server reply error")
        }
    }
    
    private func sendInfoToDevice(paymentInfo: PaymentInfo){
        
        logw("AccountPaymentViewModel sendInfoToDevice")
        
        let (ret, data) = self.secXSvrReqHandler.doPayment(payInfo: paymentInfo)
        if ret==SecuXRequestResult.SecuXRequestOK, let payInfo = data {
            
            do{
                let json  = try JSONSerialization.jsonObject(with: payInfo, options: []) as! [String : Any]
                print("sendInfoToDevice recv \(json)  \n--------")
                
                if let statusCode = json["statusCode"] as? Int, let statusDesc = json["statusDesc"] as? String{
                    if statusCode != 200{
                        self.handlePaymentDone(ret: false, errorMsg: statusDesc)
                        return
                    }
                }
                
                if let machineControlParams = json["machineControlParam"] as? [String : Any],
                    let encryptedStr = json["encryptedTransaction"] as? String,
                    let transCode = json["transactionCode"] as? String,
                    let encrypted = Data(base64Encoded: encryptedStr){
                    
                    
                    
                    logw("AccountPaymentViewModel doPaymentVerification")
                   
                    self.handlePaymentStatus(status: "Device verifying ...")
                    
                    let (ret, errorMsg) = self.paymentPeripheralManager.doPaymentVerification(encPaymentData: encrypted, machineControlParams: machineControlParams)
                    if ret == .OprationSuccess{
                        self.handlePaymentDone(ret: true, errorMsg: transCode)
                    }else{
                        self.handlePaymentDone(ret: false, errorMsg: errorMsg)
                    }
                  
                    
                }else{
                    
                    self.handlePaymentDone(ret: false, errorMsg: "Invalid payment data from server")
                    
                }
                
            }catch{
                print("doPayment error: " + error.localizedDescription)
                self.handlePaymentDone(ret: false, errorMsg: error.localizedDescription)
                
                return
            }
            
           
        }else if ret==SecuXRequestResult.SecuXRequestNoToken || ret==SecuXRequestResult.SecuXRequestUnauthorized{
            
            self.handlePaymentDone(ret: false, errorMsg: "no token")
            
        }else{
            
            print("doPayment failed!!")
            var error = "Send request to server failed."
            if let data = data{
                let msg = String(data: data, encoding: .utf8) ?? ""
                error = msg
            }
            
            self.handlePaymentDone(ret: false, errorMsg:error)
            
        }
        
    }
    
    /*
    private func handleDeviceAuthenicationResult(paymentInfo: PaymentInfo, ivKey: String?, error: Error?){
        if error != nil || ivKey == nil || ivKey?.count == 0 { // there is an error from SDK
            print("error: \(String(describing: error))")
            
            if let theError = error{
                let code = (theError as NSError).code
                if code == 25 || ivKey == nil || ivKey?.count == 0{
                     self.handlePaymentDone(ret: false, errorMsg: "No payment device")
                     return
                 }
                 //self.showMessage(title: "Error", message: msg)
                
                self.handlePaymentDone(ret: false, errorMsg: theError.localizedDescription)
            }else{
                self.handlePaymentDone(ret: false, errorMsg: "Device authentiation failed")
            }
            
           
        }else{  // get ivKey for data encryption
            self.paymentPeripheralManager.doGetIvKey { result, error in
                
               logw("AccountPaymentViewModel doGetIvKey done")
               
               
                if ((error) != nil) {
                   logw("error: \(String(describing: error))")
                   self.handlePaymentDone(ret: false, errorMsg: String(describing: error))
                   
                }else if let ivKey = result, ivKey.count > 0{
                    logw("ivKey: \(String(describing: ivKey))")
                    
                    self.handlePaymentStatus(status: "\(paymentInfo.token) transferring...")
                    
                   //DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                       
                    DispatchQueue.global(qos: .default).async{
                    
                        let paymentInfoWithIVkey = paymentInfo
                        paymentInfoWithIVkey.ivKey = ivKey
                        self.sendInfoToDevice(paymentInfo: paymentInfoWithIVkey)
                   
                   }
                   

                }else{
                   self.handlePaymentDone(ret: false, errorMsg: "No ivkey")
               }
            }
        }
    }
    */
    
    internal func doPayment(nonce:String, paymentInfo: PaymentInfo, devConfigInfo: PaymentDevConfigInfo) {
        
        logw("doPayment \(paymentInfo.amount) \(paymentInfo.deviceID) \(devConfigInfo.scanTimeout) \(devConfigInfo.connTimeout)")
        
        self.handlePaymentStatus(status: "Device connecting...")
        
        
        //let (ret, ivkey) = paymentPeripheralManager.doGetIVKey(devID: paymentInfo.deviceID)
        
        guard let nonceData = nonce.hexData else{
            handlePaymentDone(ret: false, errorMsg: "Invalid payment nonce!")
            return
        }
        
        let (ret, ivkey) = paymentPeripheralManager.doGetIVKey(devID: paymentInfo.deviceID, nonce: [UInt8](nonceData))
        if ret == .OprationSuccess{
            paymentInfo.ivKey = ivkey
            sendInfoToDevice(paymentInfo: paymentInfo)
        }else{
            handlePaymentDone(ret: false, errorMsg: ivkey)
        }
        
    }
    
    internal func doPayment(paymentInfo: PaymentInfo, devConfigInfo: PaymentDevConfigInfo) {
        
        logw("doPayment \(paymentInfo.amount) \(paymentInfo.deviceID) \(devConfigInfo.scanTimeout) \(devConfigInfo.connTimeout)")
        
        self.handlePaymentStatus(status: "Device connecting...")
        
        
        let (ret, ivkey) = paymentPeripheralManager.doGetIVKey(devID: paymentInfo.deviceID)
        if ret == .OprationSuccess{
            paymentInfo.ivKey = ivkey
            sendInfoToDevice(paymentInfo: paymentInfo)
        }else{
            handlePaymentDone(ret: false, errorMsg: ivkey)
        }
        
    }
 
    
    internal func handlePaymentDone(ret: Bool, errorMsg: String){
        DispatchQueue.main.async {
            if ret{
                self.delegate?.paymentDone(ret: ret, transactionCode: errorMsg, errorMsg: "")
            }else{
                self.delegate?.paymentDone(ret: ret, transactionCode: "", errorMsg: errorMsg)
            }
        }
    }
    
    internal func handlePaymentStatus(status: String){
        DispatchQueue.main.async {
            self.delegate?.updatePaymentStatus(status: status)
        }
    }
    

}
