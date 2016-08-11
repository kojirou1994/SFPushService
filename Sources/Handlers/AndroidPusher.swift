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
import SFJSON
import SFCurl

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
        
//        if let bodyData = pushParam.jsonString.data(using: .utf8) {
//            
//            let sign = generateSign(path: UmengPath.send, bodyString: String(data: bodyData, encoding: .utf8)!)
//            
//            var request = URLRequest(url: URL(string: UmengPath.send + "?sign=" + sign)!)
//            request.httpMethod = "POST"
//            request.httpBody = bodyData
//            
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                let re: NotificationResponse
//                if error == nil, let data = data, let response = response as? HTTPURLResponse {
//                    re = NotificationResponse(status: HTTPResponseStatus.statusFrom(code: response.statusCode), body: [UInt8](data))
//                    if let json = SFJSON(data: data) {
//                        self.completion?(re, json["data"][json["ret"].stringValue == "SUCCESS" ? "msg_id" : "error_code"].string)
//                        return
//                    }
//                }else {
//                    self.fail()
//                }
//            }
//            
//            task.resume()
//        }else {
//            self.fail()
//        }
        let requestBody = pushParam.jsonString
        let sign = generateSign(path: UmengPath.send, bodyString: requestBody)
        var request = SFURLRequest(url: UmengPath.send + "?sign=" + sign)
        // var request = SFURLRequest(url: "http://127.0.0.1:8000/post")
        request.httpMethod = .post
        request.httpBody = requestBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let response = try SFURLConnection.send(request: request)
            // dump(response)
            let bodyData = response.bodyString.cString(using: .utf8)?.map{UInt8($0)} ?? []
            let notiResponse = NotificationResponse(status: HTTPResponseStatus.statusFrom(code: response.statusCode), body: bodyData)
            if let json = SFJSON(jsonString: response.bodyString) {
                self.completion?(notiResponse, json["data"][json["ret"].stringValue == "SUCCESS" ? "msg_id" : "error_code"].string)
            }else {
                self.fail()
            }
        }catch {
            // print("Error")
            self.fail()
        }
        
    }
    
    ///发送失败
    private func fail() {
        let re = NotificationResponse(status: HTTPResponseStatus.badRequest, body: [UInt8]())
        completion?(re, nil)
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
