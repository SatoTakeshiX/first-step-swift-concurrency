import Foundation

public enum APIClientError: Error {
    case invalidURL
    case responseError
    case parseError(Error)
    case serverError(Error)
    case badStatus(statusCode: Int)
    case noData
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

public final class APIClient {
    private let session: URLSessionable
    private var baseURLString: String {
        return "https://api.github.com"
    }
    public init(session: URLSessionable) {
        self.session = session
    }

    @available(iOS 15, *)
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

    public func asyncRequest<Request>(with request: Request) async throws -> Request.Response? where Request: RequestType {
        return try await withCheckedThrowingContinuation { continuation in
            self.request(with: request) { result in
                continuation.resume(with: result)
            }
        }
    }

    @available(iOS, deprecated: 13.0, message: "替わりにasyncRequestを利用してください")
    public func request<Request>(with request: Request,
                                 completionHandler: @escaping (Result<Request.Response?, APIClientError>) -> Void) where Request: RequestType {
        guard let urlRequest = request.makeURLRequest(baseURLString: baseURLString) else {
            completionHandler(.failure(.invalidURL))
            return
        }

        requestData(with: urlRequest) { result in
            do {
                guard let data = try result.get() else {
                    completionHandler(.success(nil))
                    return
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let responseData = try decoder.decode(Request.Response.self, from: data)
                completionHandler(.success(responseData))
            } catch {
                completionHandler(.failure(error as! APIClientError))
            }
        }
    }

    @available(iOS, deprecated: 13.0, message: "替わりにasyncRequestDataを利用してください")
    public func requestData(with urlRequest: URLRequest,
                            completionHandler: @escaping (Result<Data?, APIClientError>) -> Void) {

        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completionHandler(.failure(.serverError(error)))
            } else {
                guard let httpStatus = response as? HTTPURLResponse else {
                    completionHandler(.failure(.responseError))
                    return
                }

                switch httpStatus.statusCode {
                    case 200 ..< 400:
                        completionHandler(.success(data))
                    case 400... :
                        completionHandler(.failure(.badStatus(statusCode: httpStatus.statusCode)))
                    default:
                        fatalError()
                        break
                }
            }
        }
        task.resume()
    }

    public func asyncRequestData(with urlRequest: URLRequest) async throws -> Data? {
        return try await withCheckedThrowingContinuation { continuation in
            self.requestData(with: urlRequest) { result in
                continuation.resume(with: result)
            }
        }
    }
}
