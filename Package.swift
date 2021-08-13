// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "package-syntax-parser",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "package-syntax-parser",
            targets: ["PackageSyntaxParser"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-tools-support-core.git", .branch("main")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.4.3")),
        .package(url: "https://github.com/apple/swift-syntax.git", .branch("main")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "PackageSyntaxParser",
            dependencies: [
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSyntax", package: "swift-syntax")]),
        .testTarget(
            name: "PackageSyntaxParserTests",
            dependencies: ["PackageSyntaxParser"]),
    ]
)
