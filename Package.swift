import PackageDescription

let package = Package(
    name: "SFPushService",
    dependencies:[
        .Package(url:"https://github.com/PerfectlySoft/Perfect-Notifications.git", versions: Version(0,0,0)..<Version(10,0,0)),
        .Package(url: "http://git.sfdai.com/Kojirou1994/SFMongo.git", versions: Version(0,0,0)..<Version(10,0,0)),
        .Package(url:"https://github.com/PerfectlySoft/Perfect-HTTPServer.git", versions: Version(0,0,0)..<Version(10,0,0)),
        .Package(url:"https://github.com/PerfectlySoft/Perfect-MongoDB.git", versions: Version(0,0,0)..<Version(10,0,0)),
        .Package(url:"https://github.com/kojirou1994/MD5.git", versions: Version(0,0,0)..<Version(10,0,0))
    ]
)
