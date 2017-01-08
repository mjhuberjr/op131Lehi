import PackageDescription

let package = Package(
    name: "op131",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 3),
        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 1)
    ]
)
