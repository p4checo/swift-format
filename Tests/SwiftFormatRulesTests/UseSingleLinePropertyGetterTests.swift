import SwiftFormatRules

final class UseSingleLinePropertyGetterTests: DiagnosingTestCase {
  func testMultiLinePropertyGetter() {
    XCTAssertFormatting(
      UseSingleLinePropertyGetter.self,
      input: """
             var g: Int { return 4 }
             var h: Int {
               get {
                 return 4
               }
             }
             var i: Int {
               get { return 0 }
               set { print("no set, only get") }
             }
             var j: Int {
               mutating get { return 0 }
             }
             """,
      expected: """
                var g: Int { return 4 }
                var h: Int {
                    return 4
                }
                var i: Int {
                  get { return 0 }
                  set { print("no set, only get") }
                }
                var j: Int {
                  mutating get { return 0 }
                }
                """)
  }
}
