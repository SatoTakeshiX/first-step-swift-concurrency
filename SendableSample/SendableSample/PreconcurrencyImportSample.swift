//
//  PreconcurrencyImportSample.swift
//  SendableSample
//
//  Created by satoutakeshi on 2022/04/16.
//

import Foundation
@preconcurrency import NotYetConcurrency

@MainActor
final class Animator {

    var currentPoint: Point = Point(x: 0.0, y: 0.0)

    func centerView(at location: Point) {
      Task {
          let _ = await makeCenter(current: currentPoint, to: location)
          // @Sendableクロージャー内でSendableではない型、Pointを使う
          // @preconcurrencyでimportしたので警告がでない
      }
    }
    private func makeCenter(current: Point, to: Point) async -> Double {
        return 0.0
    }
}


