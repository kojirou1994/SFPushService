//
//  Notification.swift
//  SFPushService
//
//  Created by Kojirou on 16/7/25.
//
//

import Foundation
import SFMongo

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

struct Notification: SFModel {
    var _id: ObjectId
    
    var userToken: String
    
    var app: App
    
    var title: String
    
    var body: String
    
    var badge: Int
    
    var success: Bool
    
    var time: Date
    
    init(json: JSON) throws {
        guard let id = json["_id"].oid, token = json["userToken"].string, app = App(rawValue: json["app"].intValue), title = json["title"].string, body = json["body"].string, badge = json["badge"].int, success = json["success"].bool,time = json["time"].date else {
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
    }
}

extension Notification {
    init(userToken: String, app: App, title: String, body: String, badge: Int, time: Date) {
        self._id = ObjectId.generate()
        self.userToken = userToken
        self.title = title
        self.body = body
        self.app = app
        self.badge = badge
        self.success = false
        self.time = time
    }
}
