import XCTest
import LittleHelpers

class Tests: XCTestCase {
    func test_Distinct() {
        let expectation = XCTestExpectation()
        
        var results = [String]()
        let expected = [
            "0",
            "1"
        ]
        
        let disptach = EventDispatcher(value: "0")
        disptach.observe(self, distinct: true) { (self, value) in
            results.append(value)
            if results.count == expected.count {
                expectation.fulfill()
            }
        }
        disptach.value = "0"
        disptach.value = "1"
        disptach.value = "1"
        
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(results, expected)
    }
    
    func test_Skip1() {
        let expectation = XCTestExpectation()
        
        var results = [String]()
        let expected = [
            "1",
            "2",
            "3"
        ]
        
        let disptach = EventDispatcher(value: "0")
        disptach.observe(self, skip: 1) { (self, value) in
            results.append(value)
            if results.count == expected.count {
                expectation.fulfill()
            }
        }
        disptach.value = "1"
        disptach.value = "2"
        disptach.value = "3"
        
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(results, expected)
    }
    
    func test_Skip2() {
        let expectation = XCTestExpectation()
        
        var results = [String]()
        let expected = [
            "2",
            "3"
        ]
        
        let disptach = EventDispatcher(value: "0")
        disptach.observe(self, skip: 2) { (self, value) in
            results.append(value)
            if results.count == expected.count {
                expectation.fulfill()
            }
        }
        disptach.value = "1"
        disptach.value = "2"
        disptach.value = "3"
        
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(results, expected)
    }
    
}
