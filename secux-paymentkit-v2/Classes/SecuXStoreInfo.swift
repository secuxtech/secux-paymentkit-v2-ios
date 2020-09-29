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


public class SecuXPromotion{
    /*
     {
         "type": "Promotion",
         "code": "test",
         "name": "q",
         "icon": "",
         "description": ""
       }
    */
    
    public var type = "";
    public var code = "";
    public var name = "";
    public var desc = "";
    public var imgData : Data?
    
    
    init(promotionData: Data) throws{
        if let promotionJson = try JSONSerialization.jsonObject(with: promotionData, options: []) as? [String: String]{
            
            if let proType = promotionJson["type"]{
                self.type = proType
            }
            
            if let proCode = promotionJson["code"]{
                self.code = proCode
            }
            
            if let proName = promotionJson["name"]{
                self.name = proName
            }
            
            if let proDesc = promotionJson["description"]{
                self.desc = proDesc
            }
            
            if let imgStr = promotionJson["icon"], imgStr.count > 0,
                let data = Data(base64Encoded: imgStr, options: .ignoreUnknownCharacters){
                
                self.imgData = data
                
            }
                
        }
    }
    
    init(promotionJson: [String:Any]){
            
        if let proType = promotionJson["type"] as? String{
            self.type = proType
        }
        
        if let proCode = promotionJson["code"] as? String{
            self.code = proCode
        }
        
        if let proName = promotionJson["name"] as? String{
            self.name = proName
        }
        
        if let proDesc = promotionJson["description"] as? String{
            self.desc = proDesc
        }
        
        if let imgStr = promotionJson["icon"] as? String, imgStr.count > 0,
            let data = Data(base64Encoded: imgStr, options: .ignoreUnknownCharacters){
            
            self.imgData = data
            
        }
                
    }
}

public class SecuXStoreInfo {
    
    public var code = ""
    public var name = ""
    public var devID = ""
    public var logo : UIImage?
    public var coinTokenArray = [(coin:String, token:String)]()
    public var PromotionArray = [SecuXPromotion]()
    public var info = ""
    
    init(storeData:Data) throws{
    
        //let tt = String(data: storeData, encoding: .utf8)
        
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
            
            if let promotionInfoArray = storeJson["supportedPromotion"] as? [[String:Any]]{
                for item in promotionInfoArray{
                   
                    let promotion = SecuXPromotion.init(promotionJson: item)
                    self.PromotionArray.append(promotion)
                    
                }
            }
        
        }else{
            throw SecuXStoreInfoError.invalidStoreInfo
        }
            
        
      
    }
    
    public func getPromotionDetails(code:String) -> SecuXPromotion?{
        
        for item in self.PromotionArray{
            if item.code == code{
                return item
            }
        }
        
        return nil
    }
    
}
