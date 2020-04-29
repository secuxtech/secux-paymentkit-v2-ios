//
//  LogHandler.swift
//  shippingassistant
//
//  Created by Maochun Sun on 2019/8/13.
//  Copyright © 2019 Maochun Sun. All rights reserved.
//

import Foundation


open class LogHandler {
    

    open var currentPath = LogHandler.defaultFilePath()
    
    open var printToConsole = true
    var enableLog = true

    open class var logger: LogHandler {
        
        struct Static {
            static let instance: LogHandler = LogHandler()
        }
        return Static.instance
    }
    
    //the date formatter
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        return formatter
    }
    
    ///write content to the current log file.
    open func write(_ text: String) {
        
        let dateStr = dateFormatter.string(from: Date())
        let writeText = "[\(dateStr)]: \(text)\n"
        if printToConsole {
            print(writeText, terminator: "")
        }
        
        if !self.enableLog{
            return
        }
        
        let path = currentPath
       
  
        
        if let fileHandle = FileHandle(forWritingAtPath: path) {
            
            fileHandle.seekToEndOfFile()
            fileHandle.write(writeText.data(using: String.Encoding.utf8)!)
            fileHandle.closeFile()
            
        }
    }
    
    
    
    static var directory : String = ""
    
    ///get the default log directory
    class func defaultFilePath() -> String {
        var path = ""
        var filePath = ""
        
        let fileManager = FileManager.default
        #if os(iOS)
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        path = "\(paths[0])/Logs"
        #elseif os(macOS)
        let urls = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)
        if let url = urls.last {
            path = "\(url.path)/Logs"
        }
        #endif
        
        if !fileManager.fileExists(atPath: path) && path != ""  {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
                
                
                let dateFormat:DateFormatter = DateFormatter()
                dateFormat.locale = Locale(identifier: "zh_tw")
                dateFormat.dateFormat = "yyyy-MM-dd_HH-mm-ss"
                let name = dateFormat.string(from: Date())
                
                filePath = "\(path)/\(name).txt"
                if !FileManager.default.fileExists(atPath: filePath) {
                    do {
                        try "".write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
                    } catch _ {
                    }
                }
                
            } catch _ {
            }
        }
        
        if fileManager.fileExists(atPath: path) && path != ""  {
           
                
            let dateFormat:DateFormatter = DateFormatter()
            dateFormat.locale = Locale(identifier: "zh_tw")
            dateFormat.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let name = dateFormat.string(from: Date())
            
            filePath = "\(path)/\(name).txt"
            if !FileManager.default.fileExists(atPath: filePath) {
                do {
                    try "".write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
                } catch _ {
                }
            }
                
           
        }
        
        directory = path
        
        return filePath
    }
    
    
    
}


///Writes content to the current log file
public func logw(_ text: String) {
    //LogHandler.logger.write(text)
    print(text)
}
