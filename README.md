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
print(rb.read())  // 1.0
print(rb.read())  // throws error
rb.write(1.0)
rb.write(2.0)
rb.write(3.0)
rb.write(4.0)  // throws error
``` 

### Notes

- Found it annoying that you cannot allocate an uninitialized array of some fixed size (hence passing `initialValue` into constructor)
- The array's under-the-hood capacity is actually `size + 1` to ensure `readPtr == writePtr` when empty
- Next up: do it in a struct (more swifty?)