import Foundation
import Testing
@testable import Blake3

private struct TestVector: Codable {
    let input_len: Int
    let hash: String
    let keyed_hash: String
    let derive_key: String

    func apply(_ hasher: inout Blake3) {
        for idx in 0..<input_len {
            let value: UInt8 = UInt8(idx % 251)
            hasher.update([value])
        }
    }

    func assert() {
        let hashKey: [UInt8] = Array("whats the Elvish word for friend".data(using: .ascii)!)
        let deriveKey = "BLAKE3 2019-12-27 16:29:52 test vectors context"
        var baseHash = Blake3()
        apply(&baseHash)
        #expect(baseHash.finalize().digest == hash.prefix(64), "Vector: \(input_len)")

        var keyedHash = Blake3(key: hashKey)
        apply(&keyedHash)
        #expect(keyedHash.finalize().digest == keyed_hash.prefix(64), "Vector: \(input_len)")

        var derivedKeyHash = Blake3(deriveKey: deriveKey)
        apply(&derivedKeyHash)
        #expect(derivedKeyHash.finalize().digest == derive_key.prefix(64), "Vector: \(input_len)")
    }
}

@Test("Vectors") func vectors() throws {
    let file = try #require(Bundle.module.url(forResource: "vectors", withExtension: "json"))
    try JSONDecoder().decode([TestVector].self, from: Data(contentsOf: file)).forEach { $0.assert() }
}

@Test("Valid CoW") func validCoW() {
    var hf = Blake3()
    hf.update([1, 2, 3, 4])

    var hfCopy = hf
    hf.update([5, 6, 7, 8])
    let digest = hf.finalize()

    hfCopy.update([5, 6, 7, 8])
    let copyDigest = hfCopy.finalize()

    #expect(digest == copyDigest)
}
