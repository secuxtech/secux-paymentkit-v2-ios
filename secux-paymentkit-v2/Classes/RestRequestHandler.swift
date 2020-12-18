//
//  RestServerHandler.swift
//  shippingassistant
//
//  Created by Maochun Sun on 2019/7/14.
//  Copyright © 2019 Maochun Sun. All rights reserved.
//

import Foundation

public enum SecuXRequestResult : Int{
    case SecuXRequestOK = 0
    case SecuXRequestFailed
    case SecuXRequestInvalidURL
    case SecuXRequestInvalidParameter
    case SecuXRequestUnauthorized
    case SecuXRequestNoToken
    case SecuXRequestForbiddenOperation
}


open class RestRequestHandler {
    
    private static let RequestTimeout : TimeInterval = 10000
    
   
    func postRequestSync(urlstr: String, param: Any?, withTimeout timeout:TimeInterval = RequestTimeout) -> (SecuXRequestResult, Data?){
          guard let url = URL(string: urlstr) else
          {
              print("postRequestSync invalid url")
              return (SecuXRequestResult.SecuXRequestInvalidURL, "Invalid url \(urlstr)".data(using: .utf8))
          }
        
          var request : URLRequest = URLRequest(url: url)
          
          request.httpMethod = "POST"
          request.addValue("application/json", forHTTPHeaderField: "Content-Type")
          request.addValue("application/json", forHTTPHeaderField: "Accept")
          request.timeoutInterval = timeout
        
          if let param = param{
              guard let httpBody = try? JSONSerialization.data(withJSONObject: param, options: []) else{
                  print("postRequestSync invalid httpBody")
                return (SecuXRequestResult.SecuXRequestInvalidParameter, "postRequestSync invalid httpBody".data(using: .utf8))
              }
              
              request.httpBody = httpBody
          }

          return processURLRequestSync(request: request)
      }
    
      
      func postRequestSync(urlstr: String, param: Any?, cookie:String, withTimeout timeout:TimeInterval = RequestTimeout) -> (SecuXRequestResult, Data?){
          guard let url = URL(string: urlstr) else
          {
              print("postRequestSync invalid url")
              return (SecuXRequestResult.SecuXRequestInvalidURL, "Invalid url \(urlstr)".data(using: .utf8))
          }
        
          var request : URLRequest = URLRequest(url: url)
          
          request.httpMethod = "POST"
          request.addValue("application/json", forHTTPHeaderField: "Content-Type")
          request.addValue("application/json", forHTTPHeaderField: "Accept")
          request.timeoutInterval = timeout
          
          if cookie.count > 0 {
              request.addValue(cookie, forHTTPHeaderField: "Cookie")
          }
          
          
          if let param = param{
              guard let httpBody = try? JSONSerialization.data(withJSONObject: param, options: []) else{
                  print("postRequestSync invalid httpBody")
                  return (SecuXRequestResult.SecuXRequestInvalidParameter, "postRequestSync invalid httpBody".data(using: .utf8))
              }
              
              request.httpBody = httpBody
          }
          
          
          return processURLRequestSync(request: request)
      }
      
      func postRequestSync(urlstr: String, param: Any?, token:String, withTimeout timeout:TimeInterval = RequestTimeout) -> (SecuXRequestResult, Data?){
          guard let url = URL(string: urlstr) else
          {
              print("postRequestSync invalid url")
            return (SecuXRequestResult.SecuXRequestInvalidURL, "Invalid url \(urlstr)".data(using: .utf8))
          }
        
          var request : URLRequest = URLRequest(url: url)
          
          request.httpMethod = "POST"
          request.addValue("application/json", forHTTPHeaderField: "Content-Type")
          request.addValue("application/json", forHTTPHeaderField: "Accept")
          request.timeoutInterval = timeout
          
          if token.count > 0 {
              request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
          }
          
          if let param = param{
              guard let httpBody = try? JSONSerialization.data(withJSONObject: param, options: []) else{
                  print("postRequestSync invalid httpBody")
                  return (SecuXRequestResult.SecuXRequestInvalidParameter, "postRequestSync invalid httpBody".data(using: .utf8))
              }
              
              request.httpBody = httpBody
          }
          
          return processURLRequestSync(request: request)
      }
      
    
    func processURLRequestSync(request: URLRequest) -> (SecuXRequestResult, Data?){
          
        var dataRet: Data? = nil
        var taskRet = SecuXRequestResult.SecuXRequestFailed
        
        
          
        let taskDG = DispatchGroup()
        taskDG.enter()
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
          
            if let response = response as? HTTPURLResponse{
                
                #if DEBUG
                print(request.url ?? "")
                if let requestData = request.httpBody{
                    print(String(decoding: requestData, as: UTF8.self))
                }
                #endif
                
                if response.statusCode == 200{
                    
                    #if DEBUG
                    print(request.url ?? "")
                    if let requestData = request.httpBody{
                        print(String(decoding: requestData, as: UTF8.self))
                    }
                    print(String(decoding: data!, as: UTF8.self))
                    #endif
                  
                    dataRet = data
                    taskRet = SecuXRequestResult.SecuXRequestOK
                  
                }else if response.statusCode == 401{
                    logw("Error: Unauthorized request")
                    taskRet = SecuXRequestResult.SecuXRequestUnauthorized
                    
                }else if response.statusCode == 403{
                    logw("Error: Forbidden request")
                    taskRet = SecuXRequestResult.SecuXRequestForbiddenOperation
                    dataRet = "Forbidden operation".data(using: .utf8)
                    
                }else{
                    logw("Error: \(error?.localizedDescription ?? "") url request response \(request) \(response.statusCode)")
                    
                    if let url = request.url{
                        logw("request url = \(url)")
                    }
                    
                    if let bodyData = request.httpBody, let dataStr = String(data: bodyData, encoding: String.Encoding.utf8){
                        logw("\(dataStr)")
                        
                    }
                    
                    if let data = data, let dataStr = String(data: data, encoding: String.Encoding.utf8){
                        logw("\(dataStr)")
                        
                        dataRet = data
                    }
                    
                }
          }

          taskDG.leave()
          return
        }

        task.resume()
        taskDG.wait()

        return (taskRet, dataRet)
    }
      
}
