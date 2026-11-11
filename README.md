# Blake3.swift
A Swift wrapper for the official C implementation of [BLAKE3](https://github.com/BLAKE3-team/BLAKE3).

# What is this?

This is a reimplementation of [thecoolwinter's library](https://github.com/thecoolwinter/SwiftBlake3) with various changes.

# Usage

Use just like any other hash function from the Crypto library.

```swift
import Blake3

let data: [UInt8] = [/* ... */]

// Create a one-off digest.
let digest = Blake3.digest(data)

// Stream more values
var hasher = Blake3()
for byte in data {
    hasher.update([byte])
}
let digest = hasher.finalize()

// More hasher options
let keyedHasher = Blake3(key: [UInt8])
let derivedKeyHasher = Blake3(derivedKey: "Hello World")
```

# Install

You can use the Swift Package Manager to download and import the library into your project:

```swift
dependencies: [
	.package(url: "https://github.com/nythepegasus/Blake3.swift.git", "0.0.0"..<"1.0.0"),
]
```

Then under `targets`:

```swift
targets: [
    .target(
        // ...
        dependencies: [
            .product(name: "Blake3", package: "Blake3.swift")
        ]
    )
]
```

## License

This project is licensed under the original BLAKE3 Apache license. See the [LICENSE](LICENSE) file for details.
