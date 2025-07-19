struct AlwaysEncoded<T: Encodable>: Encodable {
    let value: T?

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
