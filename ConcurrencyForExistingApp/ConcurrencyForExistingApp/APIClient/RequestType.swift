import Foundation

public protocol RequestType {
    associatedtype Response: Decodable
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    func makeURLRequest(baseURLString: String) -> URLRequest?
}

public extension RequestType {
    func makeURLRequest(baseURLString: String) -> URLRequest? {

        guard let baseURL =  URL(string: path, relativeTo: URL(string: baseURLString)) else {
            return nil
        }

        guard let components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return nil
        }

        var mutableComponents = components
        mutableComponents.queryItems = queryItems

        guard let fullURL = mutableComponents.url else {
            return nil
        }

        var request = URLRequest(url: fullURL)
        // https://docs.github.com/en/rest/reference/search#search-repositories
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        return request
    }
}

public struct SearchRepositoryRequest: RequestType {
    public typealias Response = SearchRepositoryResponse
    public var path: String { return "/search/repositories" }
    public var queryItems: [URLQueryItem]? {
        return [
            .init(name: "q", value: query),
            .init(name: "order", value: "desc")
        ]
    }

    private let query: String

    public init(query: String) {
        self.query = query
    }
}
