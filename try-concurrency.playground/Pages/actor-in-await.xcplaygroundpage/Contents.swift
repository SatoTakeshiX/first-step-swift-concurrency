//: [Previous](@previous)

import Foundation
import _Concurrency

actor Score {
    var logs: [Int] = []
    private(set) var highScore: Int = 0

    // actorのメソッド内でawaitが使われていたらデータはどうなる？
    func update(with score: Int) async {
        if score > highScore {
            // awaitの前後でプロパティを更新と外から呼び出すときの結果が変わる
            // await前で更新するとすべて同じ値になる
            logs.append(score)
            highScore = await waitTwoSecond(with: score)
            // await後で更新すると一つずつ追加していくようになる
            // データ競合はないけど挙動が変わるのに注意
            //measurements.append(measurement)

        }
    }

    func waitTwoSecond(with score: Int) async -> Int {
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)  // Two seconds
        return score
    }

}

let score = Score()
Task.detached {
    await score.update(with: 100)
    print(await score.logs)
    print(await score.highScore)

}

Task.detached {
    await score.update(with: 110)
    print(await score.logs)
    print(await score.highScore)
}

Task.detached {
    await score.update(with: 120)
    print(await score.logs)
    print(await score.highScore)

}

Task.detached {
    await score.update(with: 130)
    print(await score.logs)
    print(await score.highScore)
}

Task.detached {
    await score.update(with: 140)
    print(await score.logs)
    print(await score.highScore)
}

//: [Next](@next)
