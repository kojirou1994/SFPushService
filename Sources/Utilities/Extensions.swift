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
import SFJSON

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

public extension SFJSON {

    ///获取自定义信息
    public var extraDictionary: Dictionary<String, String>? {
        return self["extra"].dictionary as? Dictionary<String, String>
    }
}
