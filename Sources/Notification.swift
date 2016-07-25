//
//  Notification.swift
//  SFPushService
//
//  Created by Kojirou on 16/7/25.
//
//

import Foundation
import SFMongo
import Dispatch

enum App {
    case loan
    case aa
}

struct Notification: SFModel {
    var _id: ObjectId
    
    var userToken: [String]
    
    var app: App
    
    var title: String
    
    var body: String
    
    var badge: Int
    
    init(json: JSON) throws {
        <#code#>
    }
}
