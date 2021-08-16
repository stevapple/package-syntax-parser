// swift-tools-version:5.5
//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
// FIXME: This is a temporary alternative of the frontend implementation.
//
//===----------------------------------------------------------------------===//

import PackageDescription
import Foundation

let package = Package(
    name: "package-syntax-parser",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "package-syntax-parser",
            targets: ["package-syntax-parser"]),
    ],
    dependencies: [
    ],
    targets: [
        // FIXME: This target is only for testing use, SwiftPM bug?
        .target(
            name: "PackageSyntaxParser",
            dependencies: [
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSyntax", package: "swift-syntax")]),
        .executableTarget(
            name: "package-syntax-parser",
            dependencies: ["PackageSyntaxParser"]),
        .testTarget(
            name: "PackageSyntaxParserTests",
            dependencies: [
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
                .product(name: "TSCTestSupport", package: "swift-tools-support-core"),
                "PackageSyntaxParser"]),
    ]
)

if ProcessInfo.processInfo.environment["SWIFTCI_USE_LOCAL_DEPS"] == nil {
  // Building standalone.
  package.dependencies += [
    .package(url: "https://github.com/apple/swift-tools-support-core.git", .branch("main")),
    .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.4.3")),
    .package(url: "https://github.com/apple/swift-syntax", .branch("main")),
  ]
} else {
  package.dependencies += [
    .package(path: "../swift-tools-support-core"),
    .package(path: "../swift-argument-parser"),
    .package(path: "../swift-syntax"),
  ]
}
