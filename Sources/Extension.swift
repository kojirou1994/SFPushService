//
//  Extension.swift
//  SFPushService
//
//  Created by Kojirou on 16/7/26.
//
//

import PerfectNotifications

extension NotificationPusher {
    static var jucai: NotificationPusher = {
        let n = NotificationPusher()
        n.apnsTopic = "com.company.my-app"
        return n
    }()
    
    static var chedai: NotificationPusher = {
        let n = NotificationPusher()
        n.apnsTopic = "com.company.my-app"
        return n
    }()
}

extension Notification {
    
}
