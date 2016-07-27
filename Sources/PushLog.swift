//
//  PushLog.swift
//  SFPushService
//
//  Created by Kojirou on 16/7/25.
//
//

import Foundation
import SFMongo

enum PushAction: Int, JSONStringConvertible, BSONStringConvertible {
    case created
//    case sending
    case finished
    case failed
    
    var jsonString: String {
        return self.rawValue.description
    }
    
    var bsonString: String {
        return self.jsonString
    }
}

struct PushLog: SFModel {
    var _id: ObjectId
    
    var notification: ObjectId
    
    var action: PushAction
    
    var reason: String?
    
    var time: Date
    
    init(json: JSON) throws {
        guard let id = json["_id"].oid, let notification = json["notification"].oid, let action = PushAction.init(rawValue: json["action"].intValue), let time = json["time"].date else {
            throw SFMongoError.invalidData
        }
        self._id = id
        self.notification = notification
        self.action = action
        self.time = time
        self.reason = json["reason"].string
    }
}

extension PushLog {
    
    init(notification: ObjectId, action: PushAction, time: Date, reason: String? = nil) {
        self._id = ObjectId.generate()
        self.notification = notification
        self.action = action
        self.time = time
        self.reason = reason
    }
}

