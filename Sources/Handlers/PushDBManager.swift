//
//  PushLogManager.swift
//  SFPushService
//
//  Created by Kojirou on 16/7/26.
//
//

import MongoDB
import SFMongo
import Models
import SFJSON

struct PushDBManager {
    
    let client: MongoClient
    
    let logCol: MongoCollection
    
    let notiCol: MongoCollection
    
    static let `default` = {
        return try! PushDBManager(mongodb: "mongodb://localhost", database: "Push")
    }()
    
    init(mongodb: String, database: String) throws {
        client = try MongoClient(uri: mongodb)
        logCol = client.getCollection(databaseName: database, collectionName: "log")
        notiCol = client.getCollection(databaseName: database, collectionName: "notification")
    }
}

// MARK: - Notification

extension PushDBManager {
    
    func insert(notification: Notification) {
        _ = notiCol.insert(document: try! BSON(json: notification.bsonString))
    }
    
    func update(notification: Notification) {
        _ = notiCol.save(document: try! BSON(json: notification.bsonString))
    }
    
    ///设置推送是否成功
    func set(success: Bool, forNotification: ObjectId) {
        let update = try! BSON(json: "{\"$set\": {\"success\": \(success)}}")
        let selector = BSON()
        _ = selector.append(key: "_id", oid: ObjectId.parse(oid: forNotification.id))
        _ = notiCol.update(update: update, selector: selector)
    }
    
    ///获取指定Notification
    func notification(_ forNotificationId: String) -> Notification? {
        let query = BSON()
        _ = query.append(key: "_id", oid: ObjectId.parse(oid: forNotificationId))
        do {
            return try notiCol.find(query: query)?.map{return try Notification(json: SFJSON(jsonString: $0.asString)!)}.first
        }catch {
            return nil
        }
    }
    
    ///根据query查询Notification
    func notifications(_ query: BSON) -> [Notification]? {
        do {
            return try notiCol.find(query: query)?.map{return try Notification(json: SFJSON(jsonString: $0.asString)!)}
        }catch {
            return nil
        }
    }
}

// MARK: - Log

extension PushDBManager {
    
    ///插入日志
    func insert(log: PushLog, retry: Int = 0) {
        print("[Log] \(log.bsonString)")
        _ = logCol.insert(document: try! BSON(json: log.bsonString))
    }
    
    ///获取指定日志
    func log(_ forLogId: String) -> PushLog? {
        let query = BSON()
        _ = query.append(key: "_id", oid: ObjectId.parse(oid: forLogId))
        do {
            return try logCol.find(query: query)?.map{return try PushLog(json: SFJSON(jsonString: $0.asString)!)}.first
        }catch {
            return nil
        }
    }
    
    ///获取指定Notification关联日志
    func logs(_ forNotification: String) -> [PushLog]? {
        let query = BSON()
        _ = query.append(key: "notification", oid: ObjectId.parse(oid: forNotification))
        do {
            return try logCol.find(query: query)?.map{return try PushLog(json: SFJSON(jsonString: $0.asString)!)}
        }catch {
            return nil
        }
    }
}
