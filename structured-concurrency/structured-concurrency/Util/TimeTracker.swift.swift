//
//  TimeTracker.swift.swift
//  structured-concurrency
//
//  Created by satoutakeshi on 2022/01/29.
//

import Foundation

struct TimeTracker {
    static func track(_ process: (() async -> Void)) async {
        let start = Date()
        await process()
        let end = Date()
        let span = end.timeIntervalSince(start)
        let doubleDigitSpan = String(format: "%.2f", span)
        print("\(doubleDigitSpan)秒経過")
    }
}
