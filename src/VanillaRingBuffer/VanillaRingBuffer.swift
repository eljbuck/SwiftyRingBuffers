import RingBufferCore

class VanillaRingBuffer<T> {
    private let capacity: Int
    private var readPtr: Int = 0
    private var writePtr: Int = 0
    private var data: [T]

    init(size: Int, initialValue: T) throws {
        guard size > 0 else {
            throw RingBufferError.invalidSize
        }
        self.capacity = size + 1
        self.writePtr = 0
        self.readPtr = 0

        data = Array(repeating: initialValue, count: self.capacity)
    }

    func size() -> Int {
        if self.writePtr >= self.readPtr {
            return self.writePtr - self.readPtr
        }
        
        return self.capacity - (self.readPtr - self.writePtr)
    }
    
    func isEmpty() -> Bool {
        return self.size() == 0
    }
    
    func write(_ val: T) throws {
        let next = (writePtr + 1) % capacity
        guard next != readPtr else {
            throw RingBufferError.bufferFull
        }
        
        data[writePtr] = val
        writePtr = next
    }
    
    func read() throws -> T {
        guard !self.isEmpty() else {
            throw RingBufferError.bufferEmpty
        }
        
        let val = data[readPtr]
        readPtr = (readPtr + 1) % self.capacity
        return val
    }
}