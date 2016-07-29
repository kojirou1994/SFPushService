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
    
    ///单播
    case unicast = "unicast"
    
    ///列播
    case listcast = "listcast"
    
    ///文件播
    case filecast = "filecast"
    
    var jsonString: String {
        return self.rawValue
    }
    
    var maxToken: Int {
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

let UmengAppKey1 = "56b1ce2567e58ecbc8003e2a"

let UmengAppKey2 = ""

let UmengAppMasterSecret1 = "4fy7dgc8lhmnsbxc2vacc3gysbdrydgx"

let UmengAppMasterSecret2 = ""

enum AndroidPusherError: Error {
    case overload
}

class AndroidPusher {
    
    let notification: Notification
    
//    let deviceTokens: [String]
    
    let type: PushType
    
    var completion: ((succ: Bool, msgId: String?, errorCode: String?) -> ())?
    
    var pushParam: Dictionary<String, Any>
    
    init(notification: Notification, type: PushType, completion: ((succ: Bool, msgId: String?, errorCode: String?) -> ())? = nil) {
        self.notification = notification
//        self.deviceTokens = deviceTokens
        self.type = type
        self.completion = completion
        self.pushParam = Dictionary<String, Any>()
    }
    
    func push() {
        
//        try verifyTokenCount()
        
        pushParam = [
            "timestamp": Int(Date().timeIntervalSince1970),
//            "type": type,
            "type": "broadcast",
//            "device_tokens": deviceTokens.joined(separator: ","),
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
            pushParam["appkey"] = UmengAppKey2
        case .蜜蜂聚财:
            pushParam["appkey"] = UmengAppKey1
        }
        
        let bodyStr = pushParam.jsonString
        
        let bodyData = bodyStr.data(using: .utf8)
        let sign = generateSign(path: UmengSendPath, bodyString: String(data: bodyData!, encoding: .utf8)!)
        
        var request = URLRequest(url: URL(string: UmengSendPath + "?sign=" + sign)!)
        
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print(String(data: data!, encoding: .utf8))
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
    
    private func verifyTokenCount() throws {
//        if type.maxToken > 0 && deviceTokens.count > type.maxToken {
//            throw AndroidPusherError.overload
//        }
    }
    
    private func generateSign(path: String, bodyString: String) -> String {
        let method = "POST"
        let masterSecret: String
        switch notification.app {
        case .蜜蜂易车贷:
            masterSecret = UmengAppMasterSecret2
        case .蜜蜂聚财:
            masterSecret = UmengAppMasterSecret1
        }
        let joined = method + path + bodyString + masterSecret
        print("Calculating \(joined)")
//        let md5 = getMD5(joined)
//        print("Calculated \(md5)")
        return joined.md5
//        return "bfd20251e6579c9dd592268a78fea3b7"
    }
    
}
