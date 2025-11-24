# Swifty Ring Buffers

Making some ring buffers as my initial forays into the Swift world.

## Vanilla Ring Buffer

This is the basic of basic ring buffers, mirroring what I would do in C++. We have reading, writing, and size methods for a generic ring buffer.

### Usage

```swift
var rb = VanillaRingBuffer<Double>(size: 3, initialValue: 0.0)
print(rb.size())  // -> 0
print(rb.isEmpty())  // -> True
rb.write(1.0)
print(rb.read())  // -> 1.0
print(rb.read())  // -> throws error
rb.write(1.0)
rb.write(2.0)
rb.write(3.0)
rb.write(4.0)  // -> throws error
``` 

### Notes

- Found it annoying that you cannot allocate an uninitialized array of some fixed size (hence passing `initialValue` into constructor)
- The array's under-the-hood capacity is actually `size + 1` to ensure `readPtr == writePtr` when empty

## SPSC Ring Buffer (Lock Free)

This is a Single-Producer Single-Consumer circular buffer that uses the Swift Atomics class to atomically update a read and write pointer. Allows for one thread reading/writing or one thread reading/one thread writing.

### Usage

#### One Thread

```swift
let rb = SPSCRingBuffer<Double>(size: 3)
print(rb.size())  // -> 0
rb.write(1.0)
print(rb.read())  // -> 1.0
print(rb.read())  // -> nil
rb.write(1.0)
rb.write(2.0)
rb.write(3.0)
rb.write(4.0)  // -> false
``` 

#### SPSC

```swift
let rb = SPSCRingBuffer<Double>(size: 1024)

var consumed: [Int] = []
let total = 10_000

// Producer
DispatchQueue.global().async {
    for i in 0..<total {
        while !buffer.write(i) { }
    }
}

// Consumer
DispatchQueue.global().async {
    while count < total {
        if let val = buffer.read() {
            consumed.append(val)
        }
    }
}

// atp, consumed == Array(0..<total)
```

### Notes

- `initialValue` is optional in constructor but must be provided if `T` is a reference type (class) or non-trivial struct
- feat. optimizations such as: monotonically increasing ptrs with bitmask instead of `%` (requires under-the-hood array size to be rounded to next power of two), `@inline` write/read, non-blocking `read`-on-empty/`write`-on-full, and `UnsafeMutablePointer` for direct memory access

## Installation

Add this package as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/eljbuck/SwiftyRingBuffers.git", from: "1.0.0")
]
```

Then add the target to your executable or library:

```swift
.target(
    name: "MyApp",
    dependencies: ["VanillaRingBuffer", "SPSCRingBuffer"]
)
```

## Testing

Run the test suite with Swift Package Manager:


```bash
swift test
```