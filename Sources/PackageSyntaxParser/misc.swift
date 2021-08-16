/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
 
 FIXME: This is a temporary alternative of the frontend implementation.
 */

import Foundation
import SwiftSyntax

/// Consume and return the first argument from `tokens` if `label` matches.
func parseStringArgument(_ tokens: inout [TokenSyntax], label: String? = nil) throws -> String? {
    if let label = label {
        // Parse the label
        guard case .identifier(let labelString) = tokens.first?.tokenKind,
            labelString == label else {
            return nil
        }
        tokens.removeFirst()
        // Parse colon
        guard case .colon = tokens.removeFirst().tokenKind else {
            throw PackageSyntaxParserError.wrongSyntax
        }
    }
    // Parse the value
    guard case .stringLiteral(let string) = tokens.removeFirst().tokenKind else {
        throw PackageSyntaxParserError.wrongSyntax
    }
    // Eat the trailing comma
    if !tokens.isEmpty,
       tokens.removeFirst().tokenKind != .comma {
        throw PackageSyntaxParserError.wrongSyntax
    }
    return string.unescaped()
}

private extension String {
    func unescaped() -> String {
        let data = data(using: .utf8)!
        return try! JSONDecoder().decode(String.self, from: data)
    }
}
