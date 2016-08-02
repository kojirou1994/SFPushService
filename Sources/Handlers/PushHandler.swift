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
import MongoDB
import Models

public class PushHandler {
    
    public class func push(request: HTTPRequest, response: HTTPResponse) {
        //检查请求是否为空
        guard let bodyString = request.postBodyString else {
            print("No Request Body")
            response.status = .badRequest
            response.completed()
            return
        }
        //将请求body转换为JSON对象
        let json = JSON.parse(bodyString)

        //检查必须的参数是否提交
        guard let userToken = json["userToken"].string, let app = App(rawValue: json["app"].intValue), let title = json["title"].string, let body = json["body"].string, let badge = json["badge"].int else {
            print("Param not Enough")
            response.status = .badRequest
            response.completed()
            return
        }
        
        let date = Date()
        let pdb = PushDBManager.default
        
        let notification = Notification(userToken: userToken, app: app, title: title, body: body, badge: badge, time: date,device: Device(rawValue: json["device"].intValue)!, ticker: json["ticker"].string, extra: json.extraDictionary)
        
        pdb.insert(notification: notification)
        pdb.insert(log: PushLog(notification: notification._id, action: .created, time: date))
        
        //根据不同设备使用不同的接口进行推送
        notification.push { apnsResponse, message in
            let finishTime = Date()
            switch apnsResponse.status {
            case .ok:
                pdb.set(success: true, forNotification: notification._id)
                pdb.insert(log: PushLog(notification: notification._id, action: .finished, time: finishTime))
            default:
                pdb.insert(log: PushLog(notification: notification._id, action: .failed, time: finishTime, reason: message))
            }
            
            let para = [
                "userToken": userToken,
                "notification_id": notification._id.id,
                "reason": message
            ]
            
            response.status = apnsResponse.status
            response.setHeader(HTTPResponseHeader.Name.contentType, value: "application/json")
            response.setBody(string: para.jsonString)
            response.completed()

        }
        
    }
    
    public class func getLog(request: HTTPRequest, response: HTTPResponse) {
        guard let id = request.urlVariables["id"] else {
            response.completed()
            return
        }
        if let log = PushDBManager.default.log(id) {
            response.addHeader(.contentType, value: "application/json")
            response.setBody(string:  log.jsonString)
        }else {
            response.status = .notFound
            response.setBody(string: "Can not find the specific log.")
        }
        response.completed()
    }
    
    public class func getNotiLog(request: HTTPRequest, response: HTTPResponse) {
        guard let id = request.urlVariables["id"] else {
            response.completed()
            return
        }
        if let logs = PushDBManager.default.logs(id) {
            response.addHeader(.contentType, value: "application/json")
            response.setBody(string:  logs.jsonString)
        }else {
            response.status = .notFound
            response.setBody(string: "Can not find the specific logs.")
        }
        response.completed()
    }
    
    public class func getNoti(request: HTTPRequest, response: HTTPResponse) {
        guard let id = request.urlVariables["id"] else {
            response.completed()
            return
        }
        
        if let notification = PushDBManager.default.notification(id) {
            response.addHeader(.contentType, value: "application/json")
            response.setBody(string:  notification.responseBody)
        }else {
            response.status = .notFound
            response.setBody(string: "Can not find the specific notification.")
        }
        response.completed()
    }
    
    public class func findNoti(request: HTTPRequest, response: HTTPResponse) {
        let query = BSON()
        if let param = request.param(name: "app") {
            if let app = Int(param) {
                query.append(key: "app", int: app)
            }
        }
        if let param = request.param(name: "device") {
            if let device = Int(param) {
                query.append(key: "device", int: device)
            }
        }
        if let param = request.param(name: "maxtime") {
            if param.characters.count == 13, let _ = Int(param) {
                query.append(key: "time", document: try! BSON(json: "{\"$lt\": {\"$date\": \(param)} }"))
            }
        }
        if let param = request.param(name: "mintime") {
            if param.characters.count == 13, let _ = Int(param) {
                query.append(key: "time", document: try! BSON(json: "{\"$gt\": {\"$date\": \(param)} }"))
            }
        }
        if let notifications = PushDBManager.default.notifications(query) {
            response.addHeader(.contentType, value: "application/json")
            response.setBody(string:  notifications.jsonString)
        }else {
            response.status = .notFound
            response.setBody(string: "Can not find the specific notification.")
        }
        response.completed()
    }

}


extension Models.Notification {
    func push(completion: PushCompletionHandler? = nil) {
        let pusher: Pushable
        switch device {
        case .ios:
            pusher = NativeIOSPusher(notification: self, completion: completion)
        case .android:
            pusher = AndroidPusher(notification: self, completion: completion)
        }
        pusher.push()

    }
}
