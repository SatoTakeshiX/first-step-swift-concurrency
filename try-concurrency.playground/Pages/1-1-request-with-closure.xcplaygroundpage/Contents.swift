//: [Previous](@previous)

import Foundation
import PlaygroundSupport
import _Concurrency
PlaygroundPage.current.needsIndefiniteExecution = true

/*:

 # 非同期処理をクロージャーで表現する

 URLSessionのdataTaskでリクエストを行います。
 次のrequest関数はcompletionHandlerというクロージャーで結果を得られる関数です。
*/
/// urlStringで指定したURLをリクエストし、レスポンスをStringで受け取れる関数
func request(with urlString: String, completionHandler: @escaping (Result<String, APIClientError>) -> ()) {
    guard let url = URL(string: urlString) else {
        completionHandler(.failure(.invalidURL))
        return
    }

    // 処理の流れ
    // ①
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        // ③
        if let error = error {
            completionHandler(.failure(.serverError(error)))
        } else {
            guard let httpStatus = response as? HTTPURLResponse else {
                completionHandler(.failure(.responseError)) // completionHandlerを呼ぶの忘れがち
                return
            }
            switch httpStatus.statusCode {
                case 200 ..< 400:
                    guard let data = data else {
                        completionHandler(.success("")) // completionHandlerを呼ぶの忘れがち
                        return
                    }

                    guard let response = String(data: data, encoding: .utf8) else {
                        completionHandler(.failure(.noData)) // completionHandlerを呼ぶの忘れがち
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
    // ②
    task.resume()
}

/*:
 並列処理を実装する際にクロージャーで結果を得る方法はよくあるが、問題も多いです。
 まずひとつは処理が追いにくいことです。
 コードの処理は
 1. URLSession.shared.dataTaskを呼び出し、返り値であるtask変数を取得する
 2. resumeメソッドを呼び出しリクエストを開始する
 3. リクエストが完了したらdataTaskメソッドのcompletionHandlerが呼ばれる

 という流れになっています。
 通常のプログラムの処理は上から下に順次実行されますが、クロージャーを使っているため上、下、真ん中とコードを読み進めなければいけません。
 サンプルコードではクロージャーのネストはひとつでしたが、ネストが2つ、3つと増えていくと非常に読みづらいコードになってしまいます。

 次にcompletionHandler形式で関数を実装した場合、は呼び出し元は各パスで確実にcompletionHandlerが呼ばれることを想定しているが、実際にcompletionHandlerを呼び出すかは開発者の責任ということです。
 例えば、リクエストの処理中には画面にローディングViewを表示する場合を考えます。
 呼び出し元でリクエスト前にローディングViewを出し、処理が終わったらローディングViewを非表示する処理があるとするとcompletionHandlerが呼ばれないパスがあった場合、ローディングViewがいつまでも表示されてしまいます。
 クロージャーの呼び出しはSwiftコンパイラーはチェックをしないので開発者は注意深くすべてのパスでハンドラーが呼ばれるかどうかをチェックする必要があります。
 */

// クロージャーでリクエストを呼ぶ
// GitHubのリポジトリ検索API
let urlString = "https://api.github.com/search/repositories?q=swift"
// Viewにローディング画面を出すためのフラグ
var isLoading = true
request(with: urlString) { result in
    // completionHandlerの呼び出しを忘れるとisLoadingがfalseにならず、もしかしてViewのローディングがずっと表示したままになるかもしれない
    isLoading = false
    switch result {
        case .success(let responseString):
            print(responseString)
        case .failure(let error):
            print(error)
    }
}

//: [Next](@next)
