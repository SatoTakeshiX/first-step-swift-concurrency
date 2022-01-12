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

// actorのメソッド内でawaitが使われていたらデータはどうなる？

extension TemperatureLogger {
    func update(with measurement: Int) async {
        if measurement > max {
            // awaitの前後でプロパティを更新と外から呼び出すときの結果が変わる
            // await前で更新するとすべて同じ値になる
            measurements.append(measurement)
            max = await waitTwoSecond(with: measurement)
            // await後で更新すると一つずつ追加していくようになる
            // データ競合はないけど挙動が変わるのに注意
            //measurements.append(measurement)
        }
    }

    func waitTwoSecond(with measurement: Int) async -> Int {
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)  // Two seconds
        return measurement
    }
}

let logger = TemperatureLogger(measurement: 0)
Task.detached {
    await logger.update(with: 100)
    print(await logger.measurements)
    print(await logger.max)

}

Task.detached {
    await logger.update(with: 110)
    print(await logger.measurements)
    print(await logger.max)
}

//Task.detached {
//    await logger.update(with: 120)
//    print(await logger.measurements)
//    print(await logger.max)
//
//}
//
//Task.detached {
//    await logger.update(with: 130)
//    print(await logger.measurements)
//    print(await logger.max)
//}
//
//Task.detached {
//    await logger.update(with: 140)
//    print(await logger.measurements)
//    print(await logger.max)
//}

//: [Next](@next)
