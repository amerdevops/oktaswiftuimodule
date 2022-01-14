// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OktaSwiftUIModule",
    platforms: [
        // .macOS(.v10_15), .iOS(.v13)
        .macOS(.v11), .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "OktaSwiftUIModule",
            targets: ["OktaSwiftUIModule"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "OktaAuthNative", url: "https://github.com/okta/okta-auth-swift.git", from: "2.4.2"),
        .package(name: "OktaOidc", url: "https://github.com/okta/okta-oidc-ios.git", from: "3.10.8")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "OktaSwiftUIModule",
            dependencies: ["OktaAuthNative","OktaOidc"],
            resources: [
                .process("ameritas_logo_okta.png")
            ]),
        .testTarget(
            name: "OktaSwiftUIModuleTests",
            dependencies: ["OktaSwiftUIModule"]),
    ]
)
