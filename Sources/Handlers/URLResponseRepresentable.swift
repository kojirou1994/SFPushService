//
//  URLResponseRepresentable.swift
//  SFPushService
//
//  Created by Kojirou on 16/7/28.
//
//

import Foundation
import SFMongo
import Models

protocol URLResponseRepresentable {
    var responseBody: String {get}
    var responseDictionary: Dictionary<String, JSONStringConvertible?> {get}
}

extension URLResponseRepresentable {
    var responseBody: String {
        return responseDictionary.jsonString
    }
}

// MARK: - URLResponseRepresentable

extension Models.Notification: URLResponseRepresentable {
    var responseDictionary: Dictionary<String, JSONStringConvertible?> {
        let logs = PushDBManager.default.logs(_id.id) ?? []
        let res: Dictionary<String, JSONStringConvertible?> = ["_id": _id,
                                                               "userToken": userToken,
                                                               "app": app,
                                                               "ticker": ticker,
                                                               "title": title,
                                                               "body": body,
                                                               "badge": badge,
                                                               "success": success,
                                                               "time": time,
                                                               "device": device,
                                                               "extra": extra,
                                                               "logs": logs
        ]
        return res
    }
}
