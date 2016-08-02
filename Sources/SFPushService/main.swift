import PerfectNotifications
import PerfectHTTPServer
import PerfectHTTP
import PerfectLib
import PerfectNet
import SFMongo
import Foundation
import Handlers

let 蜜蜂聚财 = "蜜蜂聚财"

///设置蜜蜂聚财iOS推送证书，沙盒环境
NotificationPusher.addConfigurationIOS(name: 蜜蜂聚财) {
    (net:NetTCPSSL) in
    
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

///推送API
routes.add(method: .post, uri: "/push", handler: PushHandler.push)

///查询指定推送信息API
routes.add(method: .get, uri: "/notification/{id}", handler: PushHandler.getNoti)

///按条件查询推送信息API
routes.add(method: .get, uri: "/notification", handler: PushHandler.findNoti)

///查询指定推送的日志API
routes.add(method: .get, uri: "/notification/{id}/log", handler: PushHandler.getNotiLog)

///查询指定日至信息API
routes.add(method: .get, uri: "/log/{id}", handler: PushHandler.getLog)

server.addRoutes(routes)

server.serverPort = 8181

server.serverAddress = "127.0.0.1"

server.documentRoot = "./webroot"

do {
    ///启动服务器
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
