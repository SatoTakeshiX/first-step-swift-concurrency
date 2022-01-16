//: [Previous](@previous)

import Foundation
import _Concurrency

actor Score {
    var logs: [Int] = []
    private(set) var highScore: Int = 0

    func update(with score: Int) {
        logs.append(score)
        if score > highScore {
            highScore = score
        }
    }
}

let score = Score()

/*:
 actorを使うと必ず100, 110の結果が得られる
 */
Task.detached {
    await score.update(with: 100)
    print(await score.highScore)
}

Task.detached {
    await score.update(with: 110)
    print(await score.highScore)
}

//: [Next](@next)
