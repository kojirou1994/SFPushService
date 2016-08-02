//
//  Extensions.swift
//  
//
//  Created by Kojirou on 16/7/29.
//
//

import Foundation
import PerfectNotifications
import SFMongo

public extension NotificationPusher {
    public static var jucai: NotificationPusher = {
        let n = NotificationPusher()
        n.apnsTopic = "com.sfdai.mifengjucai"
        return n
    }()
    
    public static var chedai: NotificationPusher = {
        let n = NotificationPusher()
        n.apnsTopic = "com.company.my-app"
        return n
    }()
}

public extension JSON {

    ///获取自定义信息
    public var extraDictionary: Dictionary<String, String>? {
        
        var extra = [String: String]()
        
        for (key, value) in self["extra"].dictionaryValue {
            extra[key] = value.description
        }
        
        if extra.keys.count == 0 {
            return nil
        }
        return extra
    }
}
