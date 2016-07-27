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

enum App: Int, BSONStringConvertible, JSONStringConvertible {
    case 蜜蜂聚财 = 100
    case 蜜蜂易车贷 = 101
    
    var bsonString: String {
        return self.rawValue.description
    }
    
    var jsonString: String {
        return self.rawValue.description
    }
}

enum Device: Int, BSONStringConvertible, JSONStringConvertible {
    case ios = 0
    case android = 1
    
    var bsonString: String {
        return self.rawValue.description
    }
    
    var jsonString: String {
        return self.bsonString
    }
}


struct Notification: SFModel {
    var _id: ObjectId
    
    var userToken: String
    
    var app: App
    
    var device: Device?
    
    var title: String
    
    var body: String
    
    var badge: Int
    
    var success: Bool
    
    var time: Date
    
    init(json: JSON) throws {
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
        self.device = Device(rawValue: json["device"].intValue)
    }
}

extension Notification {
    
    init(userToken: String, app: App, title: String, body: String, badge: Int, time: Date, device: Device? = nil) {
        self._id = ObjectId.generate()
        self.userToken = userToken
        self.title = title
        self.body = body
        self.app = app
        self.badge = badge
        self.success = false
        self.time = time
        self.device = device
    }
    
    var items: [IOSNotificationItem] {
        return [.alertBody(body), .alertTitle(title), .badge(badge), .sound("default")]
    }
    
    var response: String {
        let logs = PushDBManager.shared.logs(_id.id) ?? []
        let res: Dictionary<String, Any> = ["_id": _id,
                                            "userToken": userToken,
                                            "app": app,
                                            "title": title,
                                            "body": body,
                                            "badge": badge,
                                            "success": success,
                                            "time": time,
                                            "device": device,
                                            "logs": logs]
        return res.jsonString
    }
}
