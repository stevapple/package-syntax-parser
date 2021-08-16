# `package-syntax-parser`

`package-syntax-parser` is a temporary substitute for the proposed frontend parser for the new `@package` syntax in Swift, based on [`SwiftSyntax`](https://github.com/apple/swift-syntax). _This package is a part of [Google Summer of Code](https://summerofcode.withgoogle.com) 2021 project [SwiftPM support for Swift scripts](https://summerofcode.withgoogle.com/projects/#5240743418920960)._

**NOTE: This tool is supposed to be deprecated once the corresponding frontend implementation is available.**

## Usage

```
USAGE: package-syntax-parser <file>

ARGUMENTS:
  <file>

OPTIONS:
  -h, --help              Show help information.
```

## Output

For `test.swift`:
```swift              
@package(url: "https://github.com/apple/swift-log.git", from: "1.0.0")
import Logging

@package(path: "swift-argument-parser")
import ArgumentParser

struct Count: ParsableCommand {
    @Argument var inputFile: String
    @Argument var outputFile: String

    mutating func run() throws {
        let logger = Logger(label: "com.example.Script.main")
        logger.info("""
            Counting words in '\(inputFile)' \
            and writing the result into '\(outputFile)'.
            """)

        // Read 'inputFile', count the words, and save to 'outputFile'.
    }
}
Count.main()
```

The output is:

```json
{
  "modules" : [
    {
      "package" : {
        "raw" : "url:\"https:\/\/github.com\/apple\/swift-log.git\",from:\"1.0.0\"",
        "url" : "https:\/\/github.com\/apple\/swift-log.git"
      },
      "modules" : [
        "Logging"
      ]
    },
    {
      "package" : {
        "raw" : "path:\"\/Users\/stavapple\/Developer\/swift-argument-parser\"",
        "path" : "\/Users\/stavapple\/Developer\/swift-argument-parser"
      },
      "modules" : [
        "ArgumentParser"
      ]
    }
  ],
  "sourceFile" : "\/Users\/stavapple\/Developer\/test.swift"
}
```
