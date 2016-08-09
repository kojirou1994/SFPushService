//
//  NativeIOSPusher.swift
//  SFPushService
//
//  Created by Kojirou on 16/8/2.
//
//

import Foundation
import Models
import PerfectNotifications

final class NativeIOSPusher: Pushable {

    let notification: Models.Notification
    
    var completion: PushCompletionHandler?
    
    init(notification: Models.Notification, completion: PushCompletionHandler?) {
        self.notification = notification
        self.completion = completion
    }
    
    func push() {
        let pusher: NotificationPusher
        switch notification.app {
        case .蜜蜂聚财:
            pusher = NotificationPusher.jucai
        case .蜜蜂易车贷:
            pusher = NotificationPusher.chedai
        }
        
        pusher.pushIOS(configurationName: "蜜蜂聚财", deviceToken: notification.userToken, expiration: 0, priority: 10, notificationItems: notification.items) {
            response in
            self.completion?(response, response.jsonObjectBody["reason"] as? String)
        }
    }
}
