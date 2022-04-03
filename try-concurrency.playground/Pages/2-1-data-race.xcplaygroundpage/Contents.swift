//: [Previous](@previous)

import Foundation
import _Concurrency

/*:
 データ競合を解説するコード。
 点数を管理するScoreをクラスで定義する。
 updateメソッドはlogsとhighScoreを更新する。

 */
class Score {
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
 `DispatchQueue.global`を使って複数スレッドからupdateメソッドを実行。
 highScoreをprintする。
 データ競合がなければ出力は100, 110になるはず。（順番は不同）
 */
DispatchQueue.global(qos: .default).async {
    score.update(with: 100)
    print(score.highScore)
}

DispatchQueue.global(qos: .default).async {
    score.update(with: 110)
    print(score.highScore)
}

/*:
 実行結果の一例。110が2回される場合もあるし、100が2回出力される場合もある。
 実行するたびに結果は変化する。
 同じ数値が出ている場合はデータ競合が起こっている。
 ```
 100
 100
 ```
 */

//: [Next](@next)
