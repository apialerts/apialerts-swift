import Foundation

func getEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .useDefaultKeys
    encoder.dateEncodingStrategy = .iso8601
    return encoder
}

func getDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}
