//: [Previous](@previous)

import Foundation
import PlaygroundSupport
import _Concurrency
PlaygroundPage.current.needsIndefiniteExecution = true

public enum APIClientError: Error {
    case invalidURL
    case responseError
    case parseError(Error)
    case serverError(Error)
    case badStatus(statusCode: Int)
    case noData
}

func request(with urlString: String, completionHandler: @escaping (Result<String, APIClientError>) -> ()) {
    guard let url = URL(string: urlString) else {
        completionHandler(.failure(.invalidURL))
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completionHandler(.failure(.serverError(error)))
        } else {
            guard let httpStatus = response as? HTTPURLResponse else {
                completionHandler(.failure(.responseError))
                return
            }
            switch httpStatus.statusCode {
                case 200 ..< 400:
                    guard let data = data else {
                        completionHandler(.success(""))
                        return
                    }

                    guard let response = String(data: data, encoding: .utf8) else {
                        completionHandler(.failure(.noData))
                        return
                    }
                    completionHandler(.success(response))

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

func newAsyncRequest(with urlString: String) async throws -> String {
    return try await withCheckedThrowingContinuation { continuation in
        request(with: urlString) { result in
            continuation.resume(with: result)
        }
    }
}

// 型全体に適応
@MainActor
class SomeViewModel {
    // nonisolatedでMainActorを無効にする
    nonisolated func fetchUser() {
    }
}

class AnotherViewModel {
    @MainActor var url: URL? // プロパティに適応
    @MainActor func didTapButton() {} // メソッドに適応
}

Task.detached {
    let urlString = "https://api.github.com/search/repositories?q=swift"
    let result = try await newAsyncRequest(with: urlString)
    print(result)
}

struct User {}
func fetchUser(userID: String, completionHandler: @escaping ((User?) -> ())) {
    if userID.isEmpty {
        completionHandler(nil)
    } else {
        completionHandler(User())
    }
}

func newAsyncFetchUser(userID: String) async -> User? {
    return await withCheckedContinuation { continuation in
        fetchUser(userID: userID) { user in
            continuation.resume(returning: user)
        }
    }
}


Task.detached {
    let userID = "1234"
    let user = await newAsyncFetchUser(userID: userID)
    print(user ?? "")

    let noUser = await newAsyncFetchUser(userID: "")
    print(noUser ?? "no user")
}

//: [Next](@next)
