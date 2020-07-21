//
//  SecuXStoreInfo.swift
//  secux-paymentkit-v2
//
//  Created by maochun on 2020/7/17.
//

import Foundation


enum SecuXStoreInfoError: Error {
    
    case noStoreCode
    case noStoreName
    case noStoreDevID
    case noStorIcon
    case noCoinToken
    case invalidIconData
    case invalidStoreInfo
    case invalidCoinTokenInfo
}

public class SecuXStoreInfo {
    
    public var code = ""
    public var name = ""
    public var devID = ""
    public var logo : UIImage?
    public var coinTokenArray = [(coin:String, token:String)]()
    public var info = ""
    
    init(storeData:Data) throws{
    
        
        if let storeJson = try JSONSerialization.jsonObject(with: storeData, options: []) as? [String: Any]{
            
            guard let storeInfo = String(data: storeData, encoding: .utf8) else{
                throw SecuXStoreInfoError.invalidStoreInfo
            }
            
            guard let code = storeJson["storeCode"] as? String else{
                throw SecuXStoreInfoError.noStoreCode
            }
            
            guard let name = storeJson["name"] as? String else{
                throw SecuXStoreInfoError.noStoreName
            }
            
            guard let devid = storeJson["deviceId"] as? String else{
                throw SecuXStoreInfoError.noStoreDevID
            }
            
            self.info = storeInfo
            self.code = code
            self.name = name
            self.devID = devid
            
            guard let imgStr = storeJson["icon"] as? String else{
                logw("getStoreInfo no icon  \(storeJson)")
                throw SecuXStoreInfoError.noStorIcon
            }
                
            
            guard let url = URL(string: imgStr),let data = try? Data(contentsOf: url),let image = UIImage(data: data) else{
                logw("generate store logo img failed!")
                throw SecuXStoreInfoError.invalidIconData
            }
            
            self.logo = image
            
            if let supportedCoinTokenArray = storeJson["supportedSymbol"] as? [[String]]{
                for item in supportedCoinTokenArray{
                    
                    if item.count == 2{
                        coinTokenArray.append((item[0], item[1]))
                    }else{
                        throw SecuXStoreInfoError.invalidCoinTokenInfo
                    }
                }
            }else{
                throw SecuXStoreInfoError.noCoinToken
            }
        
        }else{
            throw SecuXStoreInfoError.invalidStoreInfo
        }
            
        
      
    }
    
}
