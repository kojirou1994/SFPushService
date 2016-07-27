//
//  Utility.swift
//  SFPushService
//
//  Created by Kojirou on 16/7/27.
//
//

import MD5

func getMD5(_ calculated: String) -> String {
    let hash = MD5.calculate(calculated)
    return hash.map{String(format: "%02X", $0)}.joined(separator: "")
}

