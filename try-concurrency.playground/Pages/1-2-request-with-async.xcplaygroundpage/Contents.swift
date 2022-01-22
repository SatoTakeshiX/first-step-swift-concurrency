//: [Previous](@previous)

import Foundation
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
func request(with urlString: String) async throws -> String {
    guard let url = URL(string: urlString) else {
        throw APIClientError.invalidURL
    }
    do {
        // ①リクエスト
        let (data, urlResponse) = try await URLSession.shared.data(from: url, delegate: nil)
        guard let httpStatus = urlResponse as? HTTPURLResponse else {
            throw APIClientError.responseError
        }

        // ②ステータスコードによって処理を分ける
        switch httpStatus.statusCode {
            case 200 ..< 400:
                guard let response = String(data: data, encoding: .utf8) else {
                    throw APIClientError.noData
                }
                return response
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

/*:
 asyncで書き直したrequest関数です。
 処理は上から下に通常のコードを同じように流れていきます。
 返り値にStringを取るため、すべてのパスでreturnをするかエラーをthrowするかをしなければコンパイルエラーとなります。completionHandlerのクロージャーを使用していた時とは異なり、すべてのパスで結果を返すかthrowするかはコンパイルがチェックします。
 asyncの関数を呼び出す際はawaitキーワードが必要です。
 awaitキーワードはプログラムが停止状態になる可能性があることをシステムに伝えるものです。
 asyncのメソッドは並列処理のための特別なコンテキストで実行が必要です。
 そのコンテキストを作るためにTask.detachedを使います。
 */

Task.detached {
    do {
        let urlString = "https://api.github.com/search/repositories?q=swift"
        let response = try await request(with: urlString)
        print(response)
    } catch {
        print(error.localizedDescription)
    }
}

//: [Next](@next)
