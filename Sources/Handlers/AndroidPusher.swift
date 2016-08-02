//
//  AndroidPusher.swift
//  SFPushService
//
//  Created by Kojirou on 16/7/28.
//
//

import Foundation
import SFMongo
import Models
import PerfectNotifications
import PerfectHTTP

enum AndroidPusherError: Error {
    case overload
}

extension NotificationResponse {
    init(status: HTTPResponseStatus, body: [UInt8]) {
        self.status = status
        self.body = body
    }
}

final class AndroidPusher: Pushable {
    
    let notification: Models.Notification
    
    var completion: PushCompletionHandler?
    
    let type: UmengAndroidPushType
    
    var pushParam: Dictionary<String, JSONStringConvertible>
    
    init(notification: Models.Notification, completion: PushCompletionHandler? = nil) {
        self.notification = notification
        self.type = UmengAndroidPushType(token: notification.userToken)
        self.completion = completion
        self.pushParam = Dictionary<String, JSONStringConvertible>()
    }
    
    func push() {

        setRequestParam()
        
        if let bodyData = pushParam.jsonString.data(using: .utf8) {
            
            let sign = generateSign(path: UmengPath.send, bodyString: String(data: bodyData, encoding: .utf8)!)
            
            var request = URLRequest(url: URL(string: UmengPath.send + "?sign=" + sign)!)
            request.httpMethod = "POST"
            request.httpBody = bodyData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                let re: NotificationResponse
                if error == nil, let data = data, let response = response as? HTTPURLResponse {
                    re = NotificationResponse(status: HTTPResponseStatus.statusFrom(code: response.statusCode), body: [UInt8](data))
                    let json = JSON(data: data)
                    if json["ret"].stringValue == "SUCCESS" {
                        self.completion?(re, message: json["data"]["msg_id"].string)
                        return
                    }else {
                        self.completion?(re, message: json["data"]["error_code"].string)
                        return
                    }
                }else {
                    self.fail()
                }
            }
            
            task.resume()
        }else {
            self.fail()
        }
        
    }
    
    ///发送失败
    private func fail() {
        let re = NotificationResponse(status: HTTPResponseStatus.badRequest, body: [UInt8]())
        completion?(re, message: nil)
    }
    
    ///设置请求参数
    private func setRequestParam() {
        pushParam = [
            "timestamp": Int(Date().timeIntervalSince1970),
            "type": type,
            "device_tokens": notification.userToken,
            "payload": [
                "body": [
                    "ticker": notification.ticker ?? notification.title,
                    "title": notification.title,
                    "text": notification.body,
                    "after_open": "go_app"
                    ] as Dictionary<String, JSONStringConvertible>,
                "display_type": "notification"
                ] as Dictionary<String, JSONStringConvertible>
        ]
        
        switch notification.app {
        case .蜜蜂易车贷:
            pushParam["appkey"] = UmengAppKey.chedai
        case .蜜蜂聚财:
            pushParam["appkey"] = UmengAppKey.jucai
        }
    }
    
    ///生成MD5验证码
    private func generateSign(path: String, bodyString: String) -> String {
        let method = "POST"
        let masterSecret: String
        switch notification.app {
        case .蜜蜂易车贷:
            masterSecret = UmengAppMasterSecret.chedai
        case .蜜蜂聚财:
            masterSecret = UmengAppMasterSecret.jucai
        }
        let joined = method + path + bodyString + masterSecret
        return joined.md5
    }
    
}
