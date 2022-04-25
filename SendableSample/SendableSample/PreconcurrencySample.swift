//
//  PreconcurrencySample.swift
//  SendableSample
//
//  Created by satoutakeshi on 2022/04/16.
//

import Foundation
import NotYetConcurrency

class MyButtonIntraction {
    class MyCounter {
        var value = 0
    }

    func onClick(counter: MyCounter) {
        /*
        doSomething {
            print("tapped")
            counter.value = 1
        }
        // コンパイルエラーが発生
        // Call to main actor-isolated global function 'doSomething'
        // in a synchronous nonisolated context
        */

        // 利用者側でコード修正を強制させる？
        Task {
            await doSomething {
                print("tapped")
                // counter.value = 1
            }
        }

        doSomethingPreConcurrency {
            print("tapped")
            counter.value += 1
        }
    }

    func onClickAsync(counter: MyCounter) async {
        await doSomethingPreConcurrency {
            print("tapped")
            counter.value = 1
        }
    }
}
