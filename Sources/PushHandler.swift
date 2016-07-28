//
//  PushHandler.swift
//  SFPushService
//
//  Created by Kojirou on 16/7/27.
//
//

import PerfectHTTP
import PerfectHTTPServer
import SFMongo
import Foundation
import PerfectNotifications

typealias PushCompletionHandler = (NotificationResponse) -> ()

extension JSON: JSONStringConvertible {
    public var jsonString: String {
        return self.description
    }
}

class PushHandler {
    
    class func push(request: HTTPRequest, response: HTTPResponse) {
        
        guard let bodyString = request.postBodyString else {
            print("No Request Body")
            response.status = .badRequest
            response.completed()
            return
        }
        
        let json = JSON.parse(bodyString)
        guard let userToken = json["userToken"].string, let app = App(rawValue: json["app"].intValue), let title = json["title"].string, let body = json["body"].string, let badge = json["badge"].int else {
            print("Param not Enough")
            response.status = .badRequest
            response.completed()
            return
        }
        
        let date = Date()
        let pdb = PushDBManager.shared
        var extra = [String: String]()
        for (key, value) in json["extra"].dictionaryValue {
            extra[key] = value.jsonString
        }
        let notification = Notification(userToken: userToken, app: app, title: title, body: body, badge: badge, time: date,device: Device(rawValue: json["device"].intValue)!, ticker: json["ticker"].string, extra: extra)
        
        pdb.insert(notification: notification)
        pdb.insert(log: PushLog(notification: notification._id, action: .created, time: date))
        switch notification.device {
        case .ios:
            PushHandler.pushToIOS(notification: notification) { apnsResponse in
                let finishTime = Date()
                switch apnsResponse.status {
                case .ok:
                    pdb.set(success: true, forNotification: notification._id)
                    pdb.insert(log: PushLog(notification: notification._id, action: .finished, time: finishTime))
                default:
                    pdb.insert(log: PushLog(notification: notification._id, action: .failed, time: finishTime, reason: apnsResponse.jsonObjectBody["reason"] as? String))
                }
                
                let para = [
                    "userToken": userToken,
                    "notification_id": notification._id.id,
                    "reason": apnsResponse.jsonObjectBody["reason"]
                ]
                
                response.status = apnsResponse.status
                response.setHeader(HTTPResponseHeader.Name.contentType, value: "application/json")
                response.setBody(string: para.jsonString)
                response.completed()
            }
        case .android:
            let p = AndroidPusher(notification: notification, type: .unicast, completion: { (succ, msgId, errorCode) in
                let finishTime = Date()
                if (succ) {
                    pdb.set(success: true, forNotification: notification._id)
                    pdb.insert(log: PushLog(notification: notification._id, action: .finished, time: finishTime))
                }else {
                    pdb.insert(log: PushLog(notification: notification._id, action: .failed, time: finishTime, reason: errorCode))
                }
                let para = [
                    "userToken": userToken,
                    "notification_id": notification._id.id,
                    "reason": errorCode ?? "Null"
                ]
                
                response.status = succ ? .ok : .badRequest
                response.setHeader(HTTPResponseHeader.Name.contentType, value: "application/json")
                response.setBody(string: para.jsonString)
                response.completed()
            })
            p.push()
        }
        
    }
    
    class func getNoti(request: HTTPRequest, response: HTTPResponse) {
        guard let id = request.urlVariables["id"] else {
            response.completed()
            return
        }
        if let notification = PushDBManager.shared.notification(id) {
            response.addHeader(.contentType, value: "application/json")
            response.setBody(string:  notification.responseBody)
        }else {
            response.status = .notFound
        }
        print(response)
        response.completed()
    }
    
    private class func pushToIOS(notification: Notification, completion: PushCompletionHandler) {
        
        let pusher: NotificationPusher
        switch notification.app {
        case .蜜蜂聚财:
            pusher = NotificationPusher.jucai
        case .蜜蜂易车贷:
            pusher = NotificationPusher.chedai
        }
        
        pusher.pushIOS(configurationName: 蜜蜂聚财, deviceToken: notification.userToken, expiration: 0, priority: 10, notificationItems: notification.items, callback: completion)
    }
}
