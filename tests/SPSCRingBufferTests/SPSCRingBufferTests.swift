import XCTest
@testable import SPSCRingBuffer

final class SPSCRingBufferTest: XCTestCase {

    func testInitWithInitialValue() {
        let buffer = SPSCRingBuffer<Int>(size: 3, initialValue: { 0 })
        XCTAssertEqual(buffer.size(), 0)
    }
    
    func testInitWithoutInitialValue() {
        let buffer = SPSCRingBuffer<Int>(size: 3)
        XCTAssertEqual(buffer.size(), 0)
    }

    func testWriteAndRead() {
        let buffer = SPSCRingBuffer<Int>(size: 3)
        XCTAssertTrue(buffer.write(1))
        XCTAssertEqual(buffer.read(), 1)
        XCTAssertNil(buffer.read(), "Buffer should be empty again")
    }
    
    func testFullBuffer() {
        let buffer = SPSCRingBuffer<Int>(size: 3)
        XCTAssertTrue(buffer.write(1))
        XCTAssertTrue(buffer.write(2))
        XCTAssertTrue(buffer.write(3))
        XCTAssertFalse(buffer.write(4), "Buffer should refuse writes when full")
    }
    
    func testEmptyBuffer() {
        let buffer = SPSCRingBuffer<Int>(size: 3)
        XCTAssertTrue(buffer.write(1))
        XCTAssertTrue(buffer.write(2))
        XCTAssertTrue(buffer.write(3))
        XCTAssertEqual(buffer.read(), 1)
        XCTAssertEqual(buffer.read(), 2)
        XCTAssertEqual(buffer.read(), 3)
        XCTAssertNil(buffer.read(), "Buffer should be empty again")
    }
    
    func testWrapAround() {
        let buffer = SPSCRingBuffer<Int>(size: 3)
        XCTAssertTrue(buffer.write(1))
        XCTAssertTrue(buffer.write(2))
        XCTAssertTrue(buffer.write(3))
        XCTAssertEqual(buffer.read(), 1)
        XCTAssertTrue(buffer.write(4))
        XCTAssertEqual(buffer.read(), 2)
        XCTAssertEqual(buffer.read(), 3)
        XCTAssertEqual(buffer.read(), 4)
    }
    
    func testSizeApprox() {
        let buffer = SPSCRingBuffer<Int>(size: 3)
        XCTAssertEqual(buffer.size(), 0)
        XCTAssertTrue(buffer.write(1))
        XCTAssertTrue(buffer.write(2))
        XCTAssertTrue(buffer.write(3))
        XCTAssertFalse(buffer.write(4))
        XCTAssertEqual(buffer.size(), 3)
    }
    
    func testSPSC() {
        let buffer = SPSCRingBuffer<Int>(size: 512)
        
        let expectationProducer = expectation(description: "producer")
        let expectationConsumer = expectation(description: "consumer")
        
        var consumed: [Int] = []
        let total = 1_000_000

        // Producer
        DispatchQueue.global().async {
            for i in 0..<total {
                while !buffer.write(i) { }
            }
            expectationProducer.fulfill()
        }

        // Consumer
        DispatchQueue.global().async {
            var count = 0
            while count < total {
                if let val = buffer.read() {
                    consumed.append(val)
                    count += 1
                }
            }
            expectationConsumer.fulfill()
        }

        wait(for: [expectationProducer, expectationConsumer], timeout: 5.0)

        XCTAssertEqual(consumed.count, total)
        XCTAssertEqual(consumed, Array(0..<total))
    }
}