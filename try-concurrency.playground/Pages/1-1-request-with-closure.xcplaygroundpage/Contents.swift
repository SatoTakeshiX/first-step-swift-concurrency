//: [Previous](@previous)

import UIKit
import PlaygroundSupport
import _Concurrency
PlaygroundPage.current.needsIndefiniteExecution = true

/*:

 # 非同期処理をクロージャーで表現する

 URLSessionのdataTaskでリクエストを行います。
 次のrequest関数はcompletionHandlerというクロージャーで結果を得られる関数です。
*/
/// urlStringで指定したURLをリクエストし、レスポンスをStringで受け取れる関数
func request(url: URL, completionHandler: @escaping (Result<UIImage, Error>) -> ()) {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard error == nil else { return }
        downloadImage(data: data) { result in
            let image = try? result.get()
            resizeImage(image: image) { result in
                completionHandler(result)
            }
        }
    }
    task.resume()
}

func downloadImage(data: Data?,
                   completionHandler: @escaping (Result<UIImage, Error>) -> ()) {}

func resizeImage(image: UIImage?,
                 completionHandler: @escaping (Result<UIImage, Error>) -> ()) {}

/*:
 並列処理を実装する際にクロージャーで結果を得る方法はよくあるが、問題も多いです。
 まずひとつは処理が追いにくいことです。
 通常のプログラムの処理は上から下に順次実行されますが、クロージャーを使っているため上、下、真ん中とコードを読み進めなければいけません。
 次にコールバックで関数を実装した場合、は呼び出し元は各パスで確実にコールバックが呼ばれることを想定しているが、実際にコールバックを呼び出すかは開発者の責任ということです。
 例えば、リクエストの処理中には画面にローディングビューを表示する場合を考えます。
 呼び出し元でリクエスト前にローディングViewを出し、処理が終わったらローディングビューを非表示する処理があるとするとコールバックが呼ばれないパスがあった場合、ローディングビューがいつまでも表示されてしまいます。
 クロージャーの呼び出しはSwiftコンパイラーはチェックをしないので開発者は注意深くすべてのパスでハンドラーが呼ばれるかどうかをチェックする必要があります。
 */

let url = URL(string: "https://example.com")!
var isLoading = true
request(url: url) { result in
    // コールバックが呼ばれないとローディングビューが出っぱなしになるかもしれない
    isLoading = false
    switch result {
        case .success(let image):
            print(image)
        case .failure(let error):
            print(error.localizedDescription)
    }
}

//: [Next](@next)
