//: [Previous](@previous)

import Foundation
import _Concurrency

actor TemperatureLogger {
    var measurements: [Int]
    private(set) var max: Int

    init(measurement: Int) {
        self.measurements = [measurement]
        self.max = measurement
    }
}
// measurementsが追加されてからmaxが更新されるまでの間に並列で外から読み込まれるとデータ不整合が起こるかもしれない
// Actorはそのようなデータ不整合を守る

extension TemperatureLogger {
    func update(with measurement: Int) {
        measurements.append(measurement)
        if measurement > max {
            max = measurement
        }
    }
}

let logger = TemperatureLogger(measurement: 0)
Task.detached {
    await logger.update(with: 100)
    print(await logger.max)
}

Task.detached {
    await logger.update(with: 110)
    print(await logger.max)
}

Task.detached {
    await logger.update(with: 120)
    print(await logger.max)
}

Task.detached {
    await logger.update(with: 130)
    print(await logger.max)
}

Task.detached {
    await logger.update(with: 140)
    print(await logger.max)
}
//: [Next](@next)
