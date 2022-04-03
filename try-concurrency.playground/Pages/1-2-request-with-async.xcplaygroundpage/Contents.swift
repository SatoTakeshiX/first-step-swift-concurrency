//: [Previous](@previous)

import UIKit
import PlaygroundSupport
import _Concurrency
PlaygroundPage.current.needsIndefiniteExecution = true

/*:

 # 非同期処理をasync/awaitで表現する

 URLSessionのdataメソッドでリクエストを行います。
 クロージャー形式のものとは異なり返り値をメソッドに設定できます
*/
// asyncで定義した、urlStringで指定したURLをリクエストし、レスポンスをStringで受け取れる関数です。
// エラーをthowsで表現したバージョン



func request(url: URL) async throws -> UIImage {
    let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
    let image = try await downloadImage(data: data)
    let resizedImage = try await resizeImage(image: image)
    return resizedImage
}

func downloadImage(data: Data?) async throws -> UIImage {
    return UIImage()
}

func resizeImage(image: UIImage) async throws -> UIImage {
    return UIImage()
}

/*:
 asyncで書き直したrequest関数です。
 処理は上から下に通常のコードを同じように流れていきます。
 返り値にUIImageを取るため、すべてのパスでreturnをするかエラーをthrowするかをしなければコンパイルエラーとなります。コールバックを使用していた時とは異なり、すべてのパスで結果を返すかthrowするかはコンパイルがチェックします。
 asyncの関数を呼び出す際はawaitキーワードが必要です。
 awaitキーワードはプログラムが停止状態になる可能性があることをシステムに伝えるものです。
 asyncのメソッドは並列処理のための特別なコンテキストで実行が必要です。
 そのコンテキストを作るためにTask.detachedを使います。
 */

var isLoading = true
Task.detached {
    do {
        let url = URL(string: "https://api.github.com/search/repositories?q=swift")!
        let response = try await request(url: url)
        isLoading = false
        print(response)
    } catch {
        isLoading = false
        print(error.localizedDescription)
    }
}

//: [Next](@next)
