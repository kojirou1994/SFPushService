import PackageDescription

let package = Package(
    name: "SFPushService",
    dependencies:[
        .Package(url:"https://github.com/PerfectlySoft/Perfect-Notifications.git", versions: Version(0,0,0)..<Version(10,0,0))
    ]
)
