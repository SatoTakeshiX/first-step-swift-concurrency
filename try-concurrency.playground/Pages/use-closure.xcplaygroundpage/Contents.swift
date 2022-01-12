import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

// Only read-only property can be async
// setterがあるとasyncにできない

do {
    let client = APIClient(session: URLSession.shared)

    let request = SearchRepositoryRequest(query: "swift")
    client.request(with: request) { result in
        switch result {
            case .success(let response):
                guard let response = response else {
                    return
                }
                print(response.totalCount)
                print(response.items.first!)
            case .failure(let error):
                print(error.localizedDescription)
        }
    }
}
