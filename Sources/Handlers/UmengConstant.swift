//
//  UmengConstant.swift
//  SFPushService
//
//  Created by Kojirou on 16/8/2.
//
//

import Foundation
import SFMongo

internal struct UmengPath {
    
    static internal let send = "http://msg.umeng.com/api/send"
    
    static internal let status = "http://msg.umeng.com/api/status"
    
    static internal let cancel = "http://msg.umeng.com/api/cancel"
    
    static internal let upload = "http://msg.umeng.com/api/upload"
}

internal struct UmengAppKey {
    
    static internal let jucai = "56b1ce2567e58ecbc8003e2a"
    
    static internal let chedai = ""
}

internal struct UmengAppMasterSecret {
    
    static internal let jucai = "4fy7dgc8lhmnsbxc2vacc3gysbdrydgx"
    
    static internal let chedai = ""
}

enum UmengAndroidPushType: String, JSONStringConvertible {
    
    ///单播，只能一个设备
    case unicast = "unicast"
    
    ///列播，最多500个设备
    case listcast = "listcast"
    
    ///广播，全部
    case broadcast = "broadcast"
    
    ///文件播
    case filecast = "filecast"
    
    var jsonString: String {
        return self.rawValue.jsonString
    }
    
    var maxTokenCount: Int {
        switch self {
        case .unicast:
            return 1
        case .listcast:
            return 500
        case .broadcast:
            return 0
        case .filecast:
            return Int.max
        }
    }
    
    init(token: String) {
        if token == "" {
            self = .broadcast
        }else if token.characters.contains(",") {
            let tokenCount = token.components(separatedBy: ",").count
            switch tokenCount {
            case 2...500:
                self = .listcast
            default:
                self = .filecast
            }
        }else {
            self = .unicast
        }
    }
}
