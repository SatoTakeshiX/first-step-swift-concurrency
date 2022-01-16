//: [Previous](@previous)

import Foundation
import _Concurrency

actor A {

}

// // Actor types do not support inheritance
//actor B: A {
//
//}

actor ImageDownloader {
    var cached: [String] = []
    func image(from url: String) async -> String {
        if cached.contains(url) {
            return url
        }

        // コードはここで中断される
        // 並列にアクセスしたコードはここで止まる
        let image = await downloadImage(from: url)

        // 再開した後で、imageに対して処理をしないといけない
        // waitで取得したimageに対してcachedがあるかどうかをみないといけない
        //
       // if !cached.contains(image) {
            cached.append(image)
        //}

        // すでにあったらダウンロードしないを表現するにはどうすればいいんだ？
        // -> 不明
        // ダウンロードメソッドを叩かないようにする方法が見つからない
        return image
    }

    func downloadImage(from url: String) async -> String {
        // asyncメソッド内で早期リターン->意味ない。await前に判断ができない
        print(cached.contains(url)) // ４つすべてがfalseになる
        // awaitの後でその変数を処理するのがよい
        if cached.contains(url) {

            return url
        } else {
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)  // Two seconds
            return url
        }
    }
}

let downloader = ImageDownloader()
Task.detached {
    await downloader.image(from: "👾")
    print(await downloader.cached)
}
Task.detached {
    await downloader.image(from: "👾")
    print(await downloader.cached)
}
Task.detached {
    await downloader.image(from: "🎃")
    print(await downloader.cached)
}
Task.detached {
    await downloader.image(from: "👻")
    print(await downloader.cached)
}



//: [Next](@next)
