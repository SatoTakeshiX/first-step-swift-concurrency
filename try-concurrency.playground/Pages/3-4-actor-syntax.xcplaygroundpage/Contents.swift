//: [Previous](@previous)

import Foundation
import _Concurrency

actor A {
    var number: Int = 0
}
let a = A()
Task.detached {
    // await a.number = 1
}

actor B: Hashable {
    static func == (lhs: B, rhs: B) -> Bool {
        lhs.id == rhs.id
    }
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: UUID = UUID()
    private(set) var number = 0
    func increace() {
        number += 1
    }
}

let b = B()
let dic = [b: "xxx"]

//: [Next](@next)
