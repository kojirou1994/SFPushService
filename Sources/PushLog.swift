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
    
    var time: Date
    
    init(json: JSON) throws {
        guard let id = json["_id"].oid, notification = json["notification"].oid, action = PushAction.init(rawValue: json["action"].intValue), time = json["time"].date else {
            throw SFMongoError.invalidData
        }
        self._id = id
        self.notification = notification
        self.action = action
        self.time = time
    }
}

extension PushLog {
    init(notification: ObjectId, action: PushAction, time: Date) {
        self._id = ObjectId.generate()
        self.notification = notification
        self.action = action
        self.time = time
    }
}

