//: [Previous](@previous)

import Foundation
import _Concurrency
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

class TemperatureLogger {
    var measurements: [Int]
    private(set) var max: Int

    init(measurement: Int) {
        self.measurements = [measurement]
        self.max = measurement
    }
}

extension TemperatureLogger {
    func update(with measurement: Int) {
        measurements.append(measurement)
        // measurementsが追加されてからmaxが更新されるまでの間に並列で外から読み込まれるとデータ不整合が起こるかもしれない
        // Actorはそのようなデータ不整合を守る
        if measurement > max {
            max = measurement
        }
    }
}

let logger = TemperatureLogger(measurement: 0)

DispatchQueue.global(qos: .userInitiated).async {
    logger.update(with: 100)
    print(logger.max)
}

DispatchQueue.global(qos: .userInitiated).async {
    logger.update(with: 110)
    print(logger.max)
}

DispatchQueue.global(qos: .userInitiated).async {
    logger.update(with: 120)
    print(logger.max)
}

DispatchQueue.global(qos: .userInitiated).async {
    logger.update(with: 130)
    print(logger.max)
}

DispatchQueue.global(qos: .userInitiated).async {
    logger.update(with: 140)
    print(logger.max)
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
