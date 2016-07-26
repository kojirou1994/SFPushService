import PerfectNotifications
import PerfectHTTPServer
import PerfectHTTP
import PerfectLib
import PerfectNet
import SFMongo
import Foundation

// BEGIN one-time initialization code

let configurationName = "My configuration name - can be whatever"

NotificationPusher.addConfigurationIOS(name: configurationName) {
    (net:NetTCPSSL) in
    
    // This code will be called whenever a new connection to the APNS service is required.
    // Configure the SSL related settings.
    
    net.keyFilePassword = "if you have password protected key file"
    
    guard net.useCertificateChainFile(cert: "path/to/entrust_2048_ca.cer") &&
        net.useCertificateFile(cert: "path/to/aps_development.pem") &&
        net.usePrivateKeyFile(cert: "path/to/key.pem") &&
        net.checkPrivateKey() else {
            
            let code = Int32(net.errorCode())
            print("Error validating private key file: \(net.errorStr(forCode: code))")
            return
    }
}

NotificationPusher.development = true // set to toggle to the APNS sandbox server

// END one-time initialization code

// BEGIN - individual notification push

let deviceId = "hex string device id"
let ary = [IOSNotificationItem.alertBody("This is the message"), IOSNotificationItem.sound("default")]
let n = NotificationPusher()

n.apnsTopic = "com.company.my-app"
n.pushIOS(configurationName: configurationName, deviceToken: deviceId, expiration: 0, priority: 10, notificationItems: ary) { response in
    print("NotificationResponse: \(response.status) \(response.body)")
}

let server = HTTPServer()

var routes = Routes()

routes.add(method: .post, uri: "/push/ios") { (request, response) in
    guard let bodyString = request.postBodyString else {
        response.status = .badRequest
        response.completed()
        return
    }
    let json = JSON.parse(bodyString)
    guard let userTokens = json["userToken"].array, app = App(rawValue: json["app"].intValue), title = json["title"].string, body = json["body"].string, badge = json["badge"].int else {
        response.status = .badRequest
        response.completed()
        return
    }
    var tokens = [String]()
    for token in userTokens {
        tokens.append(token.stringValue)
    }
    let date = Date()
    let notifications = tokens.map{return Notification.init(userToken: $0, app: app, title: title, body: body, badge: badge, time: date)}
    n.pushIOS(configurationName: configurationName, deviceTokens: tokens, expiration: 0, priority: 10, notificationItems: [.alertBody(body), .alertTitle(title), .badge(badge)], callback: { (responses) in
        <#code#>
    })
    notifications.forEach{PushDBManager.shared.insert(notification: $0)}
    response.completed()
}

server.addRoutes(routes)

server.serverPort = 8181

server.serverAddress = "127.0.0.1"

server.documentRoot = "./webroot"

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
