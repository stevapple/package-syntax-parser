/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
 
 FIXME: This is a temporary alternative of the frontend implementation.
 */

import struct Foundation.URL
import SwiftSyntax
import TSCBasic

/// The model that represents a SwiftPM package dependency, or `PackageDescription.Dependency`.
struct PackageModel: Codable, Equatable {
    /// The raw body of `@package(...)`.
    let raw: String
    /// The path to the local directory of the package.
    let path: AbsolutePath?
    /// The URL of a remote package.
    let url: URL?
    /// The user-defined name for a local package.
    let name: String?

    init(_ raw: String, path: AbsolutePath? = nil, url: URL? = nil, name: String? = nil) {
        self.raw = raw
        self.path = path
        self.url = url
        self.name = name
    }
}

/// The model that represents a SwiftPM package dependency and modules from it.
struct PackageDependency: Codable, Equatable {
    /// The package dependency.
    let package: PackageModel
    /// Modules imported from the package.
    var modules: [String] = []

    init(of package: PackageModel) {
        self.package = package
    }
}

/// The model that represents parsed SwiftPM dependency info from a script.
struct ScriptDependencies: Codable, Equatable {
    /// The path to the script file.
    let sourceFile: AbsolutePath
    /// The parsed dependencies.
    let dependencies: [PackageDependency]
}

enum PackageSyntaxParserError: Swift.Error, CustomStringConvertible {
    case wrongSyntax
    case unsupportedSyntax
    case noFileSpecified

    var description: String {
        switch self {
        case .wrongSyntax:
            return "Syntax error"
        case .unsupportedSyntax:
            return "Unsupported import syntax"
        case .noFileSpecified:
            return "Please specify a file"
        }
    }
}
