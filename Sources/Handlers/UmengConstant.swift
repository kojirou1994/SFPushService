//
//  UmengConstant.swift
//  SFPushService
//
//  Created by Kojirou on 16/8/2.
//
//

import Foundation

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
