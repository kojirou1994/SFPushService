//
//  PushLog.swift
//  SFPushService
//
//  Created by Kojirou on 16/7/25.
//
//

import Foundation
import SFMongo
import SFJSON

public enum PushAction: Int, JSONStringConvertible, BSONStringConvertible {
    
    ///创建
    case created = 0
    
    ///发送完成
    case finished = 1
    
    ///发送失败
    case failed = 2
    
    public var jsonString: String {
        return self.rawValue.description
    }
    
    public var bsonString: String {
        return self.jsonString
    }
}

public struct PushLog: SFModel {
    var _id: ObjectId
    
    var notification: ObjectId
    
    var action: PushAction
    
    var reason: String?
    
    var time: Date
    
    public init(json: SFJSON) throws {
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
    
    public init(notification: ObjectId, action: PushAction, time: Date, reason: String? = nil) {
        self._id = ObjectId.generate()
        self.notification = notification
        self.action = action
        self.time = time
        self.reason = reason
    }
}

