//
//  URLResponseRepresentable.swift
//  SFPushService
//
//  Created by Kojirou on 16/7/28.
//
//

import Foundation
import SFMongo

protocol URLResponseRepresentable {
    var responseBody: String {get}
    var responseDictionary: Dictionary<String, JSONStringConvertible?> {get}
}

extension URLResponseRepresentable {
    var responseBody: String {
        return responseDictionary.jsonString
    }
}
