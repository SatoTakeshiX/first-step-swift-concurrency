//
//  ConcurrencyCode.swift
//  NotYetConcurrency
//
//  Created by satoutakeshi on 2022/04/16.
//

import Foundation

@MainActor
public func doSomething(_ body: @Sendable @escaping () -> Void) {
    Task.detached {
        body()
    }
}

@preconcurrency
@MainActor
public func doSomethingPreConcurrency(_ body: @Sendable @escaping () -> Void) {
    Task.detached {
        body()
    }
}
