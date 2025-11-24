import Atomics
import Foundation
import RingBufferCore

class SPSCRingBuffer<T> {
    private let capacity: Int
    private let mask: Int
    private let data: UnsafeMutablePointer<T>
    private let logicalSize: Int

    private let readPtr = ManagedAtomic<Int>(0)
    private let writePtr = ManagedAtomic<Int>(0)
    
    init(size: Int, initialValue: (() -> T)? = nil) {
        precondition(size > 0, "size must be greater than 0")
        
        var cap = 1
        while cap < size + 1 {
            cap = cap << 1
        }
        self.capacity = cap
        self.mask = cap - 1
        self.logicalSize = size
        self.data = UnsafeMutablePointer<T>.allocate(capacity: self.capacity)

        if let provider = initialValue {
            self.data.initialize(repeating: provider(), count: self.capacity)
        }
    }
    
    deinit {
        self.data.deallocate()
    }
    
    // this will be approximate (non-atomic)
    func size() -> Int {
        let w = writePtr.load(ordering: .relaxed)
        let r = readPtr.load(ordering: .relaxed)
        return (w - r) & mask
    }
    
    // inline for speed
    @inline(__always)
    func write(_ element: T) -> Bool {  // non-blocking for speed
        let w = self.writePtr.load(ordering: .relaxed)
        let r = self.readPtr.load(ordering: .acquiring)
        // buffer full
        let count = (w - r) & mask
        if count >= self.logicalSize { return false }

        let idx = w & mask
        self.data[idx] = element
        self.writePtr.store(w + 1, ordering: .releasing)

        return true
    }
    
    @inline(__always)
    func read() -> T? {
        let w = self.writePtr.load(ordering: .acquiring)
        let r = self.readPtr.load(ordering: .relaxed)
        // buffer empty
        if (r & mask) == (w & mask) { return nil }
        
        let idx = r & mask
        let val = self.data[idx]
        self.readPtr.store(r + 1, ordering: .releasing)

        return val
    }
}