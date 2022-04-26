//: [Previous](@previous)

import UIKit
import _Concurrency

actor Score {
    var localLogs: [Int] = []
    private(set) var highScore: Int = 0

    func update(with score: Int) async {
        // requestHighScoreを呼ぶ順番で結果が変わる
        highScore = await requestHighScore(with: score)
        localLogs.append(score)
    }

    // サーバーに点数を送るとサーバーが集計した自分の最高得点が得られると想定するメソッド
    // 実際は2秒まって引数のscoreを返すだけ
    func requestHighScore(with score: Int) async -> Int {
        try? await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)  // 2秒待つ
        return score
    }
}

let score = Score()
Task.detached {
    await score.update(with: 100)
    print(await score.localLogs)
    print(await score.highScore)
}

Task.detached {
    await score.update(with: 110)
    print(await score.localLogs)
    print(await score.highScore)
}

actor ImageDownloader {
    private var cached: [String: UIImage] = [:]

    func image(from url: String) async -> UIImage {
        // キャシュがあればそれを使う
        if cached.keys.contains(url) {
            return cached[url]!
        }
        // ダウンロード
        let image = await downloadImage(from: url)
        if !cached.keys.contains(url) {
            // キャッシュに保存
            cached[url] = image
        }
        return cached[url]!
    }

    // サーバーに画像をリクエストすることを想定するメソッド
    // 2秒後に画像をランダムで返す
    func downloadImage(from url: String) async -> UIImage {
        try? await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)  // 2秒待つ
        switch url {
            case "monster":
                // サーバー側でリソースが変わったことを表すためランダムで画像名をセット
                let imageName = Bool.random() ? "cow" : "fox"
                return UIImage(named: imageName)!
            default:
                return UIImage()
        }
    }
}

let imageDownloader = ImageDownloader()
Task.detached {
    let image = await imageDownloader.image(from: "monster")
    print(image)
//    let image2 = await imageDownloader.image(from: "monster")
//    print(image2)
}
Task.detached {
    let image = await imageDownloader.image(from: "monster")
    print(image)
}

actor ImageDownloader2 {
    private enum CacheEntry {
        case inProgress(Task<UIImage, Never>)
        case ready(UIImage)
    }

    private var cache: [String: CacheEntry] = [:]

    func image(from url: String) async -> UIImage? {
        if let cached = cache[url] {
            switch cached {
            case .ready(let image):
                return image
            case .inProgress(let task):
                return await task.value
            }
        }

        let task = Task {
            await downloadImage(from: url)
        }

        cache[url] = .inProgress(task)
        // task.valueでimageを取得
        let image = await task.value
        cache[url] = .ready(image)
        return image
    }// NSEC_PER_SEC

    func downloadImage(from url: String) async -> UIImage {
        print(NSEC_PER_SEC)
        try? await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)  // 2秒待つ
        switch url {
            case "monster":
                // サーバー側でリソースが変わったことを表すためランダムで画像名をセット
                let imageName = Bool.random() ? "cow" : "fox"
                return UIImage(named: imageName)!
            default:
                return UIImage()
        }
    }
}

let imageDownloader2 = ImageDownloader2()
Task.detached {
    let image = await imageDownloader2.image(from: "monster")
    print("image2: \(image.debugDescription)")
}
Task.detached {
    let image = await imageDownloader2.image(from: "monster")
    print("image2: \(image.debugDescription)")
}

//: [Next](@next)
