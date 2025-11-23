import XCTest
@testable import VanillaRingBuffer
@testable import RingBufferCore

final class VanillaRingBufferTests: XCTestCase {

    func testInit() throws {
        let buffer = try VanillaRingBuffer<Int>(size: 3, initialValue: 0)
        XCTAssertTrue(buffer.isEmpty())
        XCTAssertEqual(buffer.size(), 0)

        XCTAssertThrowsError(try VanillaRingBuffer<Int>(size: 0, initialValue: 0)) { error in
            XCTAssertEqual(error as? RingBufferError, .invalidSize)
        }
    }

    func testWriteAndRead() throws {
        let buffer = try VanillaRingBuffer<Int>(size: 3, initialValue: 0)
        try buffer.write(1)
        try buffer.write(2)
        XCTAssertEqual(buffer.size(), 2)
        XCTAssertFalse(buffer.isEmpty())

        XCTAssertEqual(try buffer.read(), 1)
        XCTAssertEqual(try buffer.read(), 2)
        XCTAssertTrue(buffer.isEmpty())
    }

    func testFullBuffer() throws {
        let buffer = try VanillaRingBuffer<Int>(size: 2, initialValue: 0)
        try buffer.write(10)
        try buffer.write(20)
        XCTAssertThrowsError(try buffer.write(30)) { error in
            XCTAssertEqual(error as? RingBufferError, .bufferFull)
        }
    }

    func testEmptyBuffer() throws {
        let buffer = try VanillaRingBuffer<Int>(size: 2, initialValue: 0)
        XCTAssertThrowsError(try buffer.read()) { error in
            XCTAssertEqual(error as? RingBufferError, .bufferEmpty)
        }
    }

    func testWrapAround() throws {
        let buffer = try VanillaRingBuffer<Int>(size: 3, initialValue: 0)
        try buffer.write(1)
        try buffer.write(2)
        _ = try buffer.read()    // pop 1
        try buffer.write(3)      // should wrap around

        XCTAssertEqual(try buffer.read(), 2)
        XCTAssertEqual(try buffer.read(), 3)
        XCTAssertTrue(buffer.isEmpty())
    }
}
