//: [Previous](@previous)

import UIKit
import PlaygroundSupport
import _Concurrency
PlaygroundPage.current.needsIndefiniteExecution = true

/*:
 # 順次実行と並列実行

 順次実行したい場合はawaitを並べる。
 並列実行したい場合は async letで変数を作り、変数を利用するところでawaitをつける
 */

// 画像をダウンロードする関数を定義する
// urlSessionで作って、


func request(with urlString: String) async throws -> UIImage {

    guard let url = URL(string: urlString) else {
        throw APIClientError.invalidURL
    }

    do {
        let (data, urlResponse) = try await URLSession.shared.data(from: url, delegate: nil)
        guard let httpStatus = urlResponse as? HTTPURLResponse else {
            throw APIClientError.responseError
        }

        switch httpStatus.statusCode {
            case 200 ..< 400:
                guard let image = UIImage(data: data) else {
                    throw APIClientError.noData
                }
                return image
            case 400... :
                throw APIClientError.badStatus(statusCode: httpStatus.statusCode)
            default:
                fatalError()
                break
        }
    } catch {
        throw APIClientError.serverError(error)
    }
}


func getImageByUrl(url: String) -> UIImage{
    let url = URL(string: url)
    do {
        let data = try Data(contentsOf: url!)
        return UIImage(data: data)!
    } catch let err {
        print("Error : \(err.localizedDescription)")
    }
    return UIImage()
}

let imageURLs = [
    "https://avatars.githubusercontent.com/u/10639145?v=4", // apple
    "https://avatars.githubusercontent.com/u/324574?v=4", // openstack
    "https://avatars.githubusercontent.com/u/15658638?v=4" // tensorflow
]

// 順次実行
Task.detached {

    let appleIcon = try await request(with: imageURLs[0])
    let openstack = try await request(with: imageURLs[1])
    let tensorflow = try await request(with: imageURLs[2])

    print(appleIcon, openstack, tensorflow)
}

//// 並列実行
/// 残念ながら、Xcode 13.2.1ではまだPlayground上でasync letは動かない
Task.detached {
    // async letはplaygroundでは動かないそう
    async let appleIcon = request(with: imageURLs[0])
    async let openstack = request(with: imageURLs[1])
    async let tensorflow = request(with: imageURLs[2])

    print(try await appleIcon, try await openstack, try await tensorflow)
}

//: [Next](@next)
