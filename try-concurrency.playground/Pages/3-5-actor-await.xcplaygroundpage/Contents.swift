//: [Previous](@previous)

import Foundation
import _Concurrency

actor Score {
    var localLogs: [Int] = []
    private(set) var highScore: Int = 0

    func update(with score: Int) async {
        highScore = await requestHighScore(with: score)
        localLogs.append(score)
    }

    // サーバーに点数を送るとサーバーが集計した自分の最高得点が得られると想定するメソッド
    // 実際は2秒まって引数のscoreを返すだけ
    func requestHighScore(with score: Int) async -> Int {
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)  // 2秒待つ
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

actor ScoreV2 {
    var localLogs: [Int] = []
    private(set) var highScore: Int = 0

    func update(with score: Int) async {
        let highScore = await requestHighScore(with: score)
        update(highScore: highScore, score: score)
    }

    // 同期的にプロパティを更新する
    private func update(highScore: Int, score: Int) {
        self.highScore = highScore
        localLogs.append(score)
    }
    private func requestHighScore(with score: Int) async -> Int {
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)  // 2秒待つ
        return score
    }
}

let scoreV2 = ScoreV2()
Task.detached {
    await scoreV2.update(with: 100)
    print(await scoreV2.localLogs, "v2")
    print(await scoreV2.highScore)
}

Task.detached {
    await scoreV2.update(with: 110)
    print(await scoreV2.localLogs)
    print(await scoreV2.highScore)
}


actor ImageDownloader {
    private var cached: [String: String] = [:]

    func image(from url: String) async -> String {
        if cached.keys.contains(url) {
            return cached[url]!
        }
        let image = await downloadImage(from: url)
        if !cached.keys.contains(url) {
            cached[url] = image
        }
        return cached[url]!
    }

    func downloadImage(from url: String) async -> String {
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)  // 2秒待つ
        switch url {
            case "monster":
                // サーバー側でリソースが変わったことを表すためランダムで絵文字を変える
                return Bool.random() ? "👾" : "🎃"
            default:
                return ""
        }
    }
}

let imageDownloader = ImageDownloader()
Task.detached {
    let image = await imageDownloader.image(from: "monster")
    print(image)
}
Task.detached {
    let image = await imageDownloader.image(from: "monster")
    print(image)
}

//: [Next](@next)
