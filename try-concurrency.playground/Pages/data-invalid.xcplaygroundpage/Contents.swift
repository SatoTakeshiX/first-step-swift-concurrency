//: [Previous](@previous)

import Foundation
import _Concurrency
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

class Score {
    var logs: [Int] = []
    private(set) var highScore: Int = 0

    func update(with score: Int) {
        logs.append(score)
        // measurementsが追加されてからmaxが更新されるまでの間に並列で外から読み込まれるとデータ不整合が起こるかもしれない
        // Actorはそのようなデータ不整合を守る
        if score > highScore {
            highScore = score
        }
    }
}


let score = Score()

DispatchQueue.global(qos: .userInitiated).async {
    score.update(with: 100)
    print(score.highScore)
}

DispatchQueue.global(qos: .userInitiated).async {
    score.update(with: 110)
    print(score.highScore)
}

DispatchQueue.global(qos: .userInitiated).async {
    score.update(with: 120)
    print(score.highScore)
}

DispatchQueue.global(qos: .userInitiated).async {
    score.update(with: 130)
    print(score.highScore)
}

DispatchQueue.global(qos: .userInitiated).async {
    score.update(with: 140)
    print(score.highScore)
}

/*:
 結果が次になる時があった
 100
 110
 130
 130
 140

 120がなく、130が二回出力されている。
 データ競合が起きている
 */



//: [Next](@next)
