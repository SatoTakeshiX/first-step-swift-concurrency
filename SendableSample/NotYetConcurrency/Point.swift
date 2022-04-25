//
//  Point.swift
//  NotYetConcurrency
//
//  Created by satoutakeshi on 2022/04/16.
//

import Foundation

// Sendableに準拠していない
public struct Point {
    public var x: Double
    public var y: Double
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

