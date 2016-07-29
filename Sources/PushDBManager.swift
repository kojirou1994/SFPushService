//
//  PushLogManager.swift
//  SFPushService
//
//  Created by Kojirou on 16/7/26.
//
//

import MongoDB
import SFMongo

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
    
    func set(success: Bool, forNotification: ObjectId) {
        let update = try! BSON(json: "{\"$set\": {\"success\": \(success)}}")
        let selector = BSON()
        _ = selector.append(key: "_id", oid: ObjectId.parse(oid: forNotification.id))
        let result = notiCol.update(update: update, selector: selector)
        print(result)
    }
    
    func notification(_ forNotificationId: String) -> Notification? {
        let query = BSON()
        _ = query.append(key: "_id", oid: ObjectId.parse(oid: forNotificationId))
        do {
            return try notiCol.find(query: query)?.map{return try Notification(json: JSON.parse($0.asString))}.first
        }catch {
            return nil
        }
    }
}

// MARK: - Log

extension PushDBManager {
    
    func insert(log: PushLog, retry: Int = 0) {
        print("Inserting log \(log.bsonString)")
        let result = logCol.insert(document: try! BSON(json: log.bsonString))
        switch result {
        case .success:
            return
        case .error(_, _, let info):
            print("Add Log Failed, Error Info: \(info)")
        default:
            if retry > 0 {
                insert(log: log, retry: retry - 1)
            }
        }
    }
    
    func log(_ forLogId: String) -> PushLog? {
        let query = BSON()
        _ = query.append(key: "_id", oid: ObjectId.parse(oid: forLogId))
        do {
            return try logCol.find(query: query)?.map{return try PushLog(json: JSON.parse($0.asString))}.first
        }catch {
            return nil
        }
    }
    
    func logs(_ forNotification: String) -> [PushLog]? {
        let query = BSON()
        _ = query.append(key: "notification", oid: ObjectId.parse(oid: forNotification))
        do {
            return try logCol.find(query: query)?.map{return try PushLog(json: JSON.parse($0.asString))}
        }catch {
            return nil
        }
    }
}
