import Blake3C
import Foundation

@frozen
public struct Blake3Digest: Copyable, Equatable, Sendable {
    @_transparent
    public static var size: Int { Int(BLAKE3_OUT_LEN) }

    public var bytes: (UInt64, UInt64, UInt64, UInt64)

    @_transparent
    public var data: Data {
        var b = bytes.0
        var array = [UInt8]()
        withUnsafeBytes(of: &b) { array.append(contentsOf: Array($0)) }
        b = bytes.1
        withUnsafeBytes(of: &b) { array.append(contentsOf: Array($0)) }
        b = bytes.2
        withUnsafeBytes(of: &b) { array.append(contentsOf: Array($0)) }
        b = bytes.3
        withUnsafeBytes(of: &b) { array.append(contentsOf: Array($0)) }
        return Data(array)
    }

    public var digest: String { data.map { String(format: "%02x", $0) }.joined() }

    @_transparent
    public init() { bytes = (0, 0, 0, 0) }

    @_transparent
    init(_ body: (UnsafeMutablePointer<UInt8>) -> Void) {
        self.init()
        withUnsafeMutablePointer(to: &bytes) { ptr in
            ptr.withMemoryRebound(to: UInt8.self, capacity: Self.size) { bytePointer in
                body(bytePointer)
            }
        }
    }

    @_transparent
    public func hash(into hasher: inout Hasher) {
        data.withUnsafeBytes { (b: UnsafeRawBufferPointer) in
            hasher.combine(bytes: b)
        }
    }

    @_transparent
    public static func ==(lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.bytes == rhs.bytes
    }
}

/// Implements CoW for hasher state
@usableFromInline
internal final class DigestContext: @unchecked Sendable {
    @usableFromInline
    var hasher: blake3_hasher

    @usableFromInline
    init() {
        hasher = blake3_hasher()
        blake3_hasher_init(&hasher)
    }

    @usableFromInline
    init(key: [UInt8]) {
        hasher = blake3_hasher()
        assert(key.count == BLAKE3_KEY_LEN)
        blake3_hasher_init_keyed(&hasher, key)
    }

    @usableFromInline
    init(deriveKey key: String) {
        hasher = blake3_hasher()
        blake3_hasher_init_derive_key(&hasher, key)
    }

    @usableFromInline
    init(copying: DigestContext) {
        self.hasher = copying.hasher
    }

    @usableFromInline
    func update(bufferPointer: UnsafeRawBufferPointer) {
        blake3_hasher_update(&hasher, bufferPointer.baseAddress, bufferPointer.count)
    }

    @usableFromInline
    func finalize() -> Blake3Digest {
        Blake3Digest { ptr in
            blake3_hasher_finalize(&hasher, ptr, Blake3Digest.size)
        }
    }
}

@frozen
public struct Blake3: Copyable, Sendable {
    public typealias Digest = Blake3Digest

    @inlinable
    public static var blocksize: Int { Blake3Digest.size }

    @usableFromInline
    internal var context: DigestContext

    @_transparent
    public init() {
        context = DigestContext()
    }

    @_transparent
    public init(key: [UInt8]) {
        context = DigestContext(key: key)
    }

    @_transparent
    public init(deriveKey key: String) {
        context = DigestContext(deriveKey: key)
    }

    @_transparent
    public mutating func update(_ data: any DataProtocol) {
        if !isKnownUniquelyReferenced(&self.context) {
            self.context = DigestContext(copying: self.context)
        }
        let d = Data(data)
        d.withUnsafeBytes { (b: UnsafeRawBufferPointer) in
            context.update(bufferPointer: b)
        }
    }

    @_transparent
    public func finalize() -> Blake3Digest {
        context.finalize()
    }

    public static func digest(_ data: any DataProtocol) -> Blake3Digest {
        var h = Self()
        h.update(data)
        return h.finalize()
    }
}
