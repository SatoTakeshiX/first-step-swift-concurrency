//: [Previous](@previous)
import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

let client = APIClient(session: URLSession.shared)
let request = SearchRepositoryRequest(query: "swift")
client.request(with: request) { result in
    // リクエスト結果をクロージャーで受け取る
    switch result {
        case .success(let response):
            guard let avatorURL = URL(string: response!.items.first!.owner.avatarUrl) else {
                return
            }
            let request = URLRequest(url: avatorURL)
            client.requestData(with: request) { dataResult in
                // クロージャーのネスト
                switch dataResult {
                    case .success(let data):
                        let image = UIImage(data: data!)
                        print(image!)
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        case .failure(let error):
            print(error.localizedDescription)
    }
}

//: [Next](@next)
