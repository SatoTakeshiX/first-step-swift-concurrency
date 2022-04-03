import Foundation

public class MockHTTPURLResponse: URLResponse {
    let statusCode: Int
    init(url: URL,
         mimeType: String? = nil,
         expectedContentLength: Int = 0,
         textEncodingName: String? = nil,
         statusCode: Int) {
        self.statusCode = statusCode
        super.init(url: url,
                   mimeType: mimeType,
                   expectedContentLength: expectedContentLength,
                   textEncodingName: textEncodingName)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public protocol ResponseType {
    var response: Data { get }
}

public struct SearchRepositoryResponse: Decodable {
    public let totalCount: Int
    public let items: [Repository]
}

