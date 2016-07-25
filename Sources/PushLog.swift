//
//  PushLog.swift
//  SFPushService
//
//  Created by Kojirou on 16/7/25.
//
//

import Foundation
import SFMongo

enum PushAction {
    case created
    case sending
    case finished
    case failed
}

struct PushLog: SFModel {
    var _id: ObjectId
    
    var notification: ObjectId
    
    var action: PushAction
    
    var time: Date
    
    init(json: JSON) throws {
        
    }
}
