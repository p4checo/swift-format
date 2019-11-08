import SwiftFormatConfiguration
import SwiftFormatCore
import SwiftSyntax
import XCTest

@testable import SwiftFormatPrettyPrint

public class PrettyPrintTestCase: XCTestCase {

  public func assertPrettyPrintEqual(
    input: String,
    expected: String,
    linelength: Int,
    configuration: Configuration = Configuration(),
    file: StaticString = #file,
    line: UInt = #line
  ) {
    configuration.lineLength = linelength

    // Assert that the input, when formatted, is what we expected.
    if let formatted = prettyPrintedSource(input, configuration: configuration) {
      XCTAssertDiff(
        result: formatted,
        expected: expected,
        "Pretty-printed result was not what was expected: ",
        file: file,
        line: line
      )

      // Idempotency check: Running the formatter multiple times should not change the outcome.
      // Assert that running the formatter again on the previous result keeps it the same.
      if let reformatted = prettyPrintedSource(formatted, configuration: configuration) {
        XCTAssertDiff(
          result: reformatted,
          expected: formatted,
          "Pretty printer is not idempotent: ",
          file: file,
          line: line
        )
      }
    }
  }

  /// Asserts that the two expressions have the same value, and provides a detailed
  /// message in the case there is a difference between both expression.
  ///
  /// - Parameters:
  ///   - result: The result of formatting the input code.
  ///   - expected: The expected result of formatting the input code.
  ///   - message: An optional description of the failure.
  ///   - file: The file the test resides in (defaults to the current caller's file)
  ///   - line:  The line the test resides in (defaults to the current caller's line)
  func XCTAssertDiff(
    result: String,
    expected: String,
    _ message: @autoclosure () -> String = "",
    file: StaticString,
    line: UInt
  ) {
    let resultLines = result.components(separatedBy: .newlines)
    let expectedLines = expected.components(separatedBy: .newlines)
    let minCount = min(resultLines.count, expectedLines.count)
    let maxCount = max(resultLines.count, expectedLines.count)

    var index = 0
    // Iterates through both expressions while there are no differences.
    while index < minCount && resultLines[index] == expectedLines[index] { index += 1 }

    // If the index is not the same as the number of lines, it's because a
    // difference was found.
    if maxCount != index {
      let message = message() + """
      Actual and expected have a difference on line of code \(index + 1)
      Actual line of code: "\(resultLines[index])"
      Expected line of code: "\(expectedLines[index])"
      ACTUAL:
      ("\(result)")
      EXPECTED:
      ("\(expected)")
      """
      XCTFail(message, file: file, line: line)
    }
  }

  /// Returns the given source code reformatted with the pretty printer.
  private func prettyPrintedSource(_ source: String, configuration: Configuration) -> String?
  {
    let sourceFileSyntax: SourceFileSyntax
    do {
      sourceFileSyntax = try SyntaxParser.parse(source: source)
    } catch {
      XCTFail("Parsing failed with error: \(error)")
      return nil
    }

    let context = Context(
      configuration: configuration,
      diagnosticEngine: nil,
      fileURL: URL(fileURLWithPath: "/tmp/file.swift"),
      sourceFileSyntax: sourceFileSyntax)

    let printer = PrettyPrinter(
      context: context,
      operatorContext: OperatorContext.makeBuiltinOperatorContext(),
      node: sourceFileSyntax,
      printTokenStream: false)
    return printer.prettyPrint()
  }
}
