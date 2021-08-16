/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
 
 FIXME: This is a temporary alternative of the frontend implementation.
 */

import ArgumentParser
import Foundation
import SwiftSyntax
import TSCBasic

@main
public struct PackageSyntaxParser: ParsableCommand {
    /// The source file to parse.
    @Argument var file: String

    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()

    public init() {}
}

extension PackageSyntaxParser {
    /// Parse a local source file at `path` into model.
    static func parse(_ path: AbsolutePath) throws -> ScriptDependencies {

        let syntaxTree = try SyntaxParser.parse(path.asURL)

        var inPackageScope = false
        var keyStatements: [CodeBlockItemSyntax] = []
        for statement in syntaxTree.statements {
            /// Verify if the `import` is from a package.
            if statement.statementKind == .import && inPackageScope {
                keyStatements.append(statement)
            } else {
                inPackageScope = false
            }
            /// Verify if this is a valid `@package`.
            if statement.statementKind == .package
                && statement.nextToken?.tokenKind == .importKeyword {
                inPackageScope = true
                keyStatements.append(statement)
            }
        }

        var collected: [PackageDependency] = []

        try keyStatements.forEach {
            switch $0.statementKind {
            case .package:
                /// Dropping `@` and `package`.
                var tokens = [TokenSyntax]($0.tokens.dropFirst(2))
                /// Assert and drop the parens.
                guard tokens.first?.tokenKind == .leftParen,
                      tokens.last?.tokenKind == .rightParen else {
                          throw PackageSyntaxParserError.wrongSyntax
                      }
                tokens.removeFirst()
                tokens.removeLast()
                let desc = tokens.map(\.text).joined()
                let package: PackageModel
                /// Parsing the arguments.
                if let _path = try parseStringArgument(&tokens, label: "path"),
                   case let path = AbsolutePath(_path, relativeTo: path.parentDirectory) {
                    let name = try parseStringArgument(&tokens, label: "name")
                    package = PackageModel(desc.replacingOccurrences(of: _path, with: path.pathString), path: path, name: name)
                } else if let _url = try parseStringArgument(&tokens, label: "url"),
                          let url = URL(string: _url) {
                    package = PackageModel(desc, url: url)
                } else {
                    package = PackageModel(desc)
                }
                collected.append(PackageDependency(of: package))

            case .import:
                /// Dropping `import`.
                let tokens = [TokenSyntax]($0.tokens.dropFirst())
                /// We don't support submodules currently.
                guard tokens.count == 1,
                      let moduleToken = tokens.first,
                      case .identifier(let moduleName) = moduleToken.tokenKind
                else { throw PackageSyntaxParserError.unsupportedSyntax }
                /// Update the corresponding `PackageDependency`.
                var model = collected.removeLast()
                model.modules.append(moduleName)
                collected.append(model)

            default:
                fatalError()
            }
        }
        return ScriptDependencies(sourceFile: path, modules: collected)
    }

    public func run() throws {
        let path = try AbsolutePath(validating: file)
        let json = try PackageSyntaxParser.manifest(for: path)
        print(String(decoding: json, as: UTF8.self))
    }

    /// Parse a local source file at `path` into JSON data.
    static func manifest(for path: AbsolutePath) throws -> Data {
        let output = try parse(path)
        let json = try encoder.encode(output)
        return json
    }
}
