//: [Previous](@previous)

import Foundation
import PlaygroundSupport
import _Concurrency
PlaygroundPage.current.needsIndefiniteExecution = true

// https://forums.swift.org/t/why-error-cannot-find-task-in-scope-in-xcode-playground/50507
do {
    let client = APIClient(session: URLSession.shared)
    let request = SearchRepositoryRequest(query: "swift")
    Task.detached {
        let result = await client.request(with: request)
        switch result {
            case .success(let response):
                guard let response = response else {
                    return
                }
                print(response)

            case .failure(let error):
                print(error)

        }
    }
}

//: [Next](@next)
