//
//  Pushable.swift
//  SFPushService
//
//  Created by Kojirou on 16/8/2.
//
//

import Foundation
import Models
import PerfectNotifications

typealias PushCompletionHandler = (NotificationResponse, _ message: String?) -> ()

protocol Pushable {
    
    var notification: Models.Notification {get}
    
    var completion: PushCompletionHandler? {get set}
    
    init(notification: Models.Notification, completion: PushCompletionHandler?)
    
    func push()
    
}
