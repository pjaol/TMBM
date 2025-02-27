# Time Machine Backup Manager Tests

This directory contains the test suite for the Time Machine Backup Manager (TMBM) application.

## Test Structure

The test suite is organized as follows:

- `TMBMTests/`: Contains all test files for the TMBM application
  - `TMBMTests.swift`: Basic tests for core functionality
  - `ShellCommandRunnerTests.swift`: Tests for the shell command execution utility
  - `TimeMachineServiceTests.swift`: Tests for the Time Machine service
  - `LoggerTests.swift`: Tests for the logging utility

## Running Tests

You can run the tests using Swift Package Manager:

```bash
swift test
```

Or from Xcode:

1. Open the project in Xcode
2. Select the test navigator in the navigator pane
3. Click the play button next to the test you want to run, or run all tests

## Writing New Tests

When adding new functionality to the application, please add corresponding tests. Follow these guidelines:

1. Create a new test file in the `TMBMTests/` directory if testing a new component
2. Name the test file after the component being tested, with the suffix `Tests`
3. Import `XCTest` and `@testable import TMBM` at the top of the file
4. Create a test class that inherits from `XCTestCase`
5. Add test methods that begin with `test`
6. Use assertions to verify expected behavior

Example:

```swift
import XCTest
@testable import TMBM

final class NewComponentTests: XCTestCase {
    func testSomeFeature() {
        // Test code here
        XCTAssertEqual(actualValue, expectedValue)
    }
}
```

## Test Coverage

The goal is to maintain high test coverage for all critical components of the application, especially:

- Shell command execution
- Time Machine operations
- Error handling
- Data formatting and parsing
- User preference management 