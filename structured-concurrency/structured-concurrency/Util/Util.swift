//
//  Util.swift
//  structured-concurrency
//
//  Created by satoutakeshi on 2022/02/01.
//

import Foundation

struct Util {
    static func wait(seconds: UInt64) async {
        try? await Task.sleep(nanoseconds: seconds * NSEC_PER_SEC)
    }
}
