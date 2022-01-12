import Foundation

public enum APIClientError: Error {
    case invalidURL
    case responseError
    case parseError(Error)
    case serverError(Error)
    case badStatus(statusCode: Int)
    case noData
}

public protocol APIClientable: AnyObject {
    var baseURLString: String { get }

// URLSessionをmockできるようにする
    func request<Request>(with request: Request, resultHandler: @escaping (Result<Request.Response?, APIClientError>) -> Void) where Request: RequestType
}

public extension APIClientable {
    var baseURLString: String {
        return "https://api.github.com"
    }
}

public protocol URLSessionable {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask

    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask

    @available(iOS 15.0, *)
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)

    @available(iOS 15.0, *)
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionable {}

public final class APIClient: APIClientable {

    private let session: URLSessionable

    public init(session: URLSessionable) {
        self.session = session
    }

    public func request<Request>(with request: Request) async -> Result<Request.Response?, APIClientError> where Request: RequestType {
        guard let urlRequest = request.makeURLRequest(baseURLString: baseURLString) else {
            return .failure(.invalidURL)
        }

        do {
            let (data, urlResponse) = try await session.data(for: urlRequest, delegate: nil)
            guard let httpStatus = urlResponse as? HTTPURLResponse else {
                return .failure(.responseError)
            }

            switch httpStatus.statusCode {
                case 200 ..< 400:
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let responseData = try decoder.decode(Request.Response.self, from: data)
                        return .success(responseData)
                    } catch {
                        return .failure(.parseError(error))
                    }
                case 400... :
                    return .failure(.badStatus(statusCode: httpStatus.statusCode))
                default:
                    fatalError()
                    break
            }
        } catch {
            return .failure(.serverError(error))
        }
    }

    public func request<Request>(with request: Request, resultHandler: @escaping (Result<Request.Response?, APIClientError>) -> Void) where Request: RequestType {

        guard let urlRequest = request.makeURLRequest(baseURLString: baseURLString) else {
            resultHandler(.failure(.invalidURL))
            return
        }

        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                resultHandler(.failure(.serverError(error)))
            } else {
                guard let httpStatus = response as? HTTPURLResponse else {
                    resultHandler(.failure(.responseError))
                    return
                }

                switch httpStatus.statusCode {
                    case 200 ..< 400:
                        guard let data = data else {
                            resultHandler(.success(nil))
                            return
                        }
                        do {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let responseData = try decoder.decode(Request.Response.self, from: data)
                            resultHandler(.success(responseData))
                        } catch {
                            resultHandler(.failure(.parseError(error)))
                        }
                    case 400... :
                        resultHandler(.failure(.badStatus(statusCode: httpStatus.statusCode)))
                    default:
                        fatalError()
                        break
                }
            }
        }

        task.resume()
    }
}
