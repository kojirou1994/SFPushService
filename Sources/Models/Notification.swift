//
//  Notification.swift
//  SFPushService
//
//  Created by Kojirou on 16/7/25.
//
//

import Foundation
import SFMongo
import PerfectNotifications
import Utilities

public enum App: Int, BSONStringConvertible, JSONStringConvertible {
    case 蜜蜂聚财 = 100
    case 蜜蜂易车贷 = 101
    
    public var bsonString: String {
        return self.rawValue.description
    }
    
    public var jsonString: String {
        return self.rawValue.description
    }
}

public enum Device: Int, BSONStringConvertible, JSONStringConvertible {
    case ios = 0
    case android = 1
    
    public var bsonString: String {
        return self.rawValue.description
    }
    
    public var jsonString: String {
        return self.bsonString
    }
}


public struct Notification: SFModel {

    /// MongoDB ID
    public var _id: ObjectId
    
    ///推送目标token
    public var userToken: String
    
    ///指定推送app
    public var app: App
    
    ///推送设备类型
    public var device: Device
    
    ///推送通知标题
    public var title: String
    
    ///推送通知主体内容
    public var body: String
    
    ///iOS角标
    public var badge: Int
    
    ///是否推送成功
    public var success: Bool
    
    ///请求时间
    public var time: Date
    
    ///for Android Only
    public var ticker: String?
    
    ///additional info
    public var extra: Dictionary<String, String>?
    
    public init(json: JSON) throws {
        guard let id = json["_id"].oid, let token = json["userToken"].string, let app = App(rawValue: json["app"].intValue), let title = json["title"].string, let body = json["body"].string, let badge = json["badge"].int, let success = json["success"].bool,let time = json["time"].date else {
            throw SFMongoError.invalidData
        }
        self._id = id
        self.userToken = token
        self.app = app
        self.title = title
        self.body = body
        self.badge = badge
        self.success = success
        self.time = time
        self.device = Device(rawValue: json["device"].intValue)!
        self.ticker = json["ticker"].string
        self.extra = json.extraDictionary
    }
}

extension Notification {
    
    public init(userToken: String, app: App, title: String, body: String, badge: Int, time: Date, device: Device, ticker: String? = nil, extra: Dictionary<String, String>? = nil) {
        self._id = ObjectId.generate()
        self.userToken = userToken
        self.title = title
        self.body = body
        self.app = app
        self.badge = badge
        self.success = false
        self.time = time
        self.device = device
        self.ticker = ticker
        self.extra = extra
    }
    
    public var items: [IOSNotificationItem] {
        return [.alertBody(body), .alertTitle(title), .badge(badge), .sound("default")]
    }
}
