//
//  SecuXServerRequestHandler.swift
//  SecuXWallet
//
//  Created by Maochun Sun on 2019/12/2.
//  Copyright © 2019 Maochun Sun. All rights reserved.
//

import Foundation


class SecuXServerFWRequestHandler: RestRequestHandler {
    
    static let BaseSvrUrl = "https://pmsweb-test.secux.io/api/"
    static let LoginUrl = BaseSvrUrl + "Admin/Login"
    static let FWDataUrl = BaseSvrUrl + "Device/Upgrade"
    
    public override init() {
        super.init()
    
    }

    public func loginSvr(account:String, password:String) -> String{
        
        var token = ""
        let param = ["account": account, "password":password]
        let (ret, data) = self.postRequestSync(urlstr: SecuXServerFWRequestHandler.LoginUrl, param: param)
        if ret == SecuXRequestResult.SecuXRequestOK, let replyData = data{
        
            let jsonObj  = ((try? JSONSerialization.jsonObject(with: replyData, options: []) as? [String : Any]) as [String : Any]??)
            if let jsonObj = jsonObj, let tokenStr = jsonObj?["token"] as? String{
                token = tokenStr
            }
            
        }else{
            print("Login failed!")
        }
        
        return token
        
    }
    
    public func getFWData(serialNo:String, modelType:String, fwVersion:String, token:String) -> String{
        
        var fwStr = ""
        let param = ["serialNo":serialNo, "modelType":modelType, "firmwareVersion":fwVersion]
        let (ret, data) = self.postRequestSync(urlstr: SecuXServerFWRequestHandler.FWDataUrl, param: param, token: token)
        if ret == SecuXRequestResult.SecuXRequestOK, let replyData = data{
            
            let jsonObj  = ((try? JSONSerialization.jsonObject(with: replyData, options: []) as? [String : Any]) as [String : Any]??)
            if let jsonObj = jsonObj, let fw = jsonObj?["firmwareFile"] as? String{
                 fwStr = fw
            }
            
        }else{
            print("getFWData failed!")
        }
        return fwStr
    }
    
}
