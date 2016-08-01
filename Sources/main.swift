import PerfectNotifications
import PerfectHTTPServer
import PerfectHTTP
import PerfectLib
import PerfectNet
import SFMongo
import Foundation

let 蜜蜂聚财 = "蜜蜂聚财"

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

routes.add(method: .post, uri: "/push", handler: PushHandler.push)

routes.add(method: .get, uri: "/notification/{id}", handler: PushHandler.getNoti)

routes.add(method: .get, uri: "/notification/{id}/log", handler: PushHandler.getNotiLog)

routes.add(method: .get, uri: "/log/{id}", handler: PushHandler.getLog)

server.addRoutes(routes)

server.serverPort = 8181

server.serverAddress = "127.0.0.1"

server.documentRoot = "./webroot"

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
