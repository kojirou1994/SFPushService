//
//  Pusher.swift
//  SFPushService
//
//  Created by Kojirou on 16/7/27.
//
//

import PerfectHTTP
import SFMongo
import Foundation
import PerfectNotifications

class Pusher {
    class func pushIOS(request: HTTPRequest, response: HTTPResponse) {
        guard let bodyString = request.postBodyString else {
            print("No Request Body")
            response.status = .badRequest
            response.completed()
            return
        }
        let json = JSON.parse(bodyString)
        guard let userTokens = json["userToken"].array, app = App(rawValue: json["app"].intValue), title = json["title"].string, body = json["body"].string, badge = json["badge"].int else {
            print("Param not Enough")
            response.status = .badRequest
            response.completed()
            return
        }
        let tokens = userTokens.map{return $0.stringValue}
        print(tokens)
        let date = Date()
        let notifications = tokens.map{return Notification.init(userToken: $0, app: app, title: title, body: body, badge: badge, time: date)}
        notifications.forEach {
            PushDBManager.shared.insert(notification: $0)
            PushDBManager.shared.add(log: PushLog(notification: $0._id, action: .created, time: date))
        }
        let pusher: NotificationPusher
        switch app {
        case .蜜蜂聚财:
            pusher = NotificationPusher.jucai
        case .蜜蜂易车贷:
            pusher = NotificationPusher.jucai
        }
        pusher.pushIOS(configurationName: 蜜蜂聚财, deviceTokens: tokens, expiration: 0, priority: 10, notificationItems: [.alertBody(body), .alertTitle(title), .badge(badge)], callback: { (responses) in
            print(responses)
            let time = Date()
            var data = [String]()
            for (index, response) in responses.enumerated() {
                print("\(response.status) \(response.stringBody)")
                let notification = notifications[index]
                let para = [
                    "userToken": notification.userToken,
                    "status": response.status.description,
                    "message": response.stringBody
                ]
                data.append(para.jsonString)
                switch response.status {
                case .ok:
                    PushDBManager.shared.set(notification: notification._id, success: true)
                    PushDBManager.shared.add(log: PushLog(notification: notification._id, action: .finished, time: time))
                case .custom(let code, let message):
                    print(code)
                    print(message)
                default:
                    break
                }
            }
            response.setHeader(HTTPResponseHeader.Name.contentType, value: "application/json")
            response.setBody(string: "[" + data.joined(separator: ",") + "]")
            response.completed()
        })

    }
    
    class func pushAndroid(request: HTTPRequest, response: HTTPResponse) {
        
    }
}
