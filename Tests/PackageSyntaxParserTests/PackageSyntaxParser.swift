/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
 
 FIXME: This is a temporary alternative of the frontend implementation.
 */
@testable import PackageSyntaxParser
import SwiftSyntax
import TSCBasic
import TSCTestSupport
import XCTest

final class PackageSyntaxParserTests: XCTestCase {
    let supportedSourceString = """
        @package(path: "/path/to/package", name: "my-package")
        import MyLibrary
        import MyLibraryV2
        
        print(MyLibrary.text)
        """
    
    let alternativeSourceString = """
        @package(url: "https://localhost:8000/path/to/package", from: "1.0.0")
        import MyLibrary
        """
    
    let unsupportedSourceString = """
        @package(path: import)
        import MyLibrary.V3
        """
    
    func testStatementKind() throws {
        do {
            let syntaxTree = try SyntaxParser.parse(source: supportedSourceString)
            let statementKinds = syntaxTree.statements.map(\.statementKind)
            XCTAssertEqual(statementKinds.count, 4)
            XCTAssertEqual(statementKinds, [.package, .import, .import, .others])
        }
        
        do {
            let syntaxTree = try SyntaxParser.parse(source: unsupportedSourceString)
            let statementKinds = syntaxTree.statements.map(\.statementKind)
            XCTAssertEqual(statementKinds.count, 2)
            XCTAssertEqual(statementKinds, [.package, .import])
        }
    }
    
    func testParse() throws {
        try withTemporaryFile { file in
            try file.fileHandle.write(contentsOf: supportedSourceString.data(using: .utf8)!)
            let parsed = try PackageSyntaxParser.parse(file.path)
            XCTAssertEqual(parsed.modules.count, 1)
            let packageDependency = parsed.modules.first!
            XCTAssertEqual(packageDependency.modules, ["MyLibrary", "MyLibraryV2"])
            XCTAssertEqual(packageDependency.package.path, AbsolutePath("/path/to/package"))
            XCTAssertNil(packageDependency.package.url)
            XCTAssertEqual(packageDependency.package.name, "my-package")
            XCTAssertEqual(packageDependency.package.raw, "path:\"/path/to/package\",name:\"my-package\"")
        }
        
        try withTemporaryFile { file in
            try file.fileHandle.write(contentsOf: alternativeSourceString.data(using: .utf8)!)
            let parsed = try PackageSyntaxParser.parse(file.path)
            XCTAssertEqual(parsed.modules.count, 1)
            let packageDependency = parsed.modules.first!
            XCTAssertEqual(packageDependency.modules, ["MyLibrary"])
            XCTAssertNil(packageDependency.package.path)
            XCTAssertEqual(packageDependency.package.url, URL(string: "https://localhost:8000/path/to/package"))
            XCTAssertNil(packageDependency.package.name)
            XCTAssertEqual(packageDependency.package.raw,
                           "url:\"https://localhost:8000/path/to/package\",from:\"1.0.0\"")
        }
    }
    
    func testPrint() throws {
        try [supportedSourceString, alternativeSourceString].forEach { string in
            try withTemporaryFile { file in
                try file.fileHandle.write(contentsOf: string.data(using: .utf8)!)
                let parsed = try PackageSyntaxParser.parse(file.path)
                let encoded = try JSONEncoder().encode(parsed)
                XCTAssertNotNil(String(data: encoded, encoding: .utf8))
                let decoded = try JSONDecoder().decode(ScriptDependencies.self, from: encoded)
                XCTAssertEqual(parsed, decoded)
            }
        }
    }
}
