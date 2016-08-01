//
//  AndroidPusher.swift
//  SFPushService
//
//  Created by Kojirou on 16/7/28.
//
//

import Foundation
import SFMongo

enum PushType: String, JSONStringConvertible {
    
    ///单播，只能一个设备
    case unicast = "unicast"
    
    ///列播，最多500个设备
    case listcast = "listcast"
    
    ///广播，全部
    case broadcast = "broadcast"
    
    ///文件播
    case filecast = "filecast"
    
    var jsonString: String {
        return self.rawValue
    }
    
    var maxTokenCount: Int {
        switch self {
        case .unicast:
            return 1
        case .listcast:
            return 500
        default:
            return 0
        }
    }
}

let UmengSendPath = "http://msg.umeng.com/api/send"

let UmengStatusPath = "http://msg.umeng.com/api/status"

let UmengCancelPath = "http://msg.umeng.com/api/cancel"

let UmengUploadPath = "http://msg.umeng.com/api/upload"

let UmengAppKeyJUCAI = "56b1ce2567e58ecbc8003e2a"

let UmengAppKeyCHEDAI = ""

let UmengAppMasterSecretJUCAI = "4fy7dgc8lhmnsbxc2vacc3gysbdrydgx"

let UmengAppMasterSecretCHEDAI = ""

enum AndroidPusherError: Error {
    case overload
}

class AndroidPusher {
    
    let notification: Notification
    
    let type: PushType
    
    var completion: ((succ: Bool, msgId: String?, errorCode: String?) -> ())?
    
    var pushParam: Dictionary<String, JSONStringConvertible>
    
    init(notification: Notification, completion: ((succ: Bool, msgId: String?, errorCode: String?) -> ())? = nil) {
        self.notification = notification
        if notification.userToken == "" {
            self.type = .broadcast
        }else if notification.userToken.characters.contains(",") {
            self.type = .listcast
        }else {
            self.type = .unicast
        }
        self.completion = completion
        self.pushParam = Dictionary<String, JSONStringConvertible>()
    }
    
    func push() {
        do {
            try verifyTokenCount()
        }catch {
            self.completion?(succ: false, msgId: nil, errorCode: "Too many tokens")
        }
        
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
            pushParam["appkey"] = UmengAppKeyCHEDAI
        case .蜜蜂聚财:
            pushParam["appkey"] = UmengAppKeyJUCAI
        }
        
        let bodyStr = pushParam.jsonString
        
        let bodyData = bodyStr.data(using: .utf8)
        let sign = generateSign(path: UmengSendPath, bodyString: String(data: bodyData!, encoding: .utf8)!)
        
        var request = URLRequest(url: URL(string: UmengSendPath + "?sign=" + sign)!)
        
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error == nil && data != nil {
                let json = JSON(data: data!)
                if json["ret"].stringValue == "SUCCESS" {
                    self.completion?(succ: true, msgId: json["data"]["msg_id"].string, errorCode: nil)
                    return
                }else {
                    self.completion?(succ: false, msgId: nil, errorCode: json["data"]["error_code"].string)
                    return
                }
            }
            self.completion?(succ: false, msgId: nil, errorCode: nil)
        }
        task.resume()
    }
    
    ///检察tokencount没有超出上限
    private func verifyTokenCount() throws {
        let tokenCount = notification.userToken.components(separatedBy: ",").count
        let maxCount = type.maxTokenCount
        if  maxCount > 0 && tokenCount > maxCount {
            throw AndroidPusherError.overload
        }
    }
    
    private func generateSign(path: String, bodyString: String) -> String {
        let method = "POST"
        let masterSecret: String
        switch notification.app {
        case .蜜蜂易车贷:
            masterSecret = UmengAppMasterSecretCHEDAI
        case .蜜蜂聚财:
            masterSecret = UmengAppMasterSecretJUCAI
        }
        let joined = method + path + bodyString + masterSecret
        return joined.md5
    }
    
}
