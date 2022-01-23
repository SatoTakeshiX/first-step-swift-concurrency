//: [Previous](@previous)

import Foundation
import _Concurrency

// async関数
func a() async {
    print(#function)
}
//Task.detached {
//    a()
//}
//
//a()

// 戻り値のあるasync関数
func b() async -> String {
    return "result"
}
Task.detached {
    let result = await b()
    print(result)
}

struct AsyncError: Error {
    let message: String
}

func c(showError: Bool) async throws {
    if showError {
        throw AsyncError(message: "error")
    } else {
        print("no error")
    }
}
Task.detached {
    do {
        try await c(showError: true)
    } catch {
        print(error.localizedDescription)
    }
}

class D {
    init(label: String) async {
        print("イニシャライザーでasync")
    }
}

Task.detached {
    _ = await D(label: "")
}

Task.detached {
    let result = await b()
    let d = await D(label: result)
    print(d)
}

Task.detached {
    let d = await D(label: b())
    print(d)
}

//: [Next](@next)
