import PerfectNotifications
import PerfectHTTPServer
import PerfectHTTP
import PerfectLib
import PerfectNet
import SFMongo
import Foundation

let configurationName = "My configuration name - can be whatever"

NotificationPusher.addConfigurationIOS(name: configurationName) {
    (net:NetTCPSSL) in
    net.keyFilePassword = ""
    
    guard net.useCertificateChainFile(cert: "./cert/entrust_2048_ca.cer") &&
        net.useCertificateFile(cert: "./cert/push_development.pem") &&
        net.usePrivateKeyFile(cert: "./cert/PrivateKeyFile.pem") &&
        net.checkPrivateKey() else {
            let code = Int32(net.errorCode())
            print("Error validating private key file: \(net.errorStr(forCode: code))")
            return
    }
}

NotificationPusher.development = true

let server = HTTPServer()

var routes = Routes()

routes.add(method: .post, uri: "/push/ios") { (request, response) in
    guard let bodyString = request.postBodyString else {
        print("No Request Body")
        response.status = .badRequest
        response.completed()
        return
    }
    let json = JSON.parse(bodyString)
    guard let userTokens = json["userToken"].array, app = App(rawValue: json["app"].intValue), title = json["title"].string, body = json["body"].string, badge = json["badge"].int else {
        print("Param not Enough")
        response.status = .badRequest
        response.completed()
        return
    }
    let tokens = userTokens.map{return $0.stringValue}
    print(tokens)
    let date = Date()
    let notifications = tokens.map{return Notification.init(userToken: $0, app: app, title: title, body: body, badge: badge, time: date)}
    notifications.forEach {
        PushDBManager.shared.insert(notification: $0)
        PushDBManager.shared.add(log: PushLog(notification: $0._id, action: .created, time: date))
    }
    let pusher: NotificationPusher
    switch app {
    case .蜜蜂聚财:
        pusher = NotificationPusher.jucai
    case .蜜蜂易车贷:
        pusher = NotificationPusher.jucai
    }
    pusher.pushIOS(configurationName: configurationName, deviceTokens: tokens, expiration: 0, priority: 10, notificationItems: [.alertBody(body), .alertTitle(title), .badge(badge)], callback: { (responses) in
        print(responses)
        let time = Date()
        var data = [String]()
        for (index, response) in responses.enumerated() {
            print("\(response.status) \(response.stringBody)")
            let notification = notifications[index]
            let para = [
                "userToken": notification.userToken,
                "status": response.status.description,
                "message": response.stringBody
            ]
            data.append(para.jsonString)
            switch response.status {
            case .ok:
                PushDBManager.shared.set(notification: notification._id, success: true)
                PushDBManager.shared.add(log: PushLog(notification: notification._id, action: .finished, time: time))
            case .custom(let code, let message):
                print(code)
                print(message)
            default:
                break
            }
        }
        response.setHeader(HTTPResponseHeader.Name.contentType, value: "application/json")
        response.setBody(string: "[" + data.joined(separator: ",") + "]")
        response.completed()
    })
    
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
