//: [Previous](@previous)

import Foundation
import _Concurrency

struct A: Sendable {}
let a = A()
//print(a is Sendable)
//print(a as? Sendable)

struct SendableOK: Sendable {
    var title: String
    var message: String
}

//struct SendableNG: Sendable {
//    var title: String
//    var message: NSString
//}

//extension Score: Sendable {}

// publicでないなら暗黙的に準拠
struct Person {
    var name: String
    var age: Int
}

// publicなので暗黙的に準拠しない
public struct Person2 {
    var name: String
}

// publicでも@frozenなので暗黙的に準拠
@frozen public struct Person3 {
    var name: String
}

// ItemがSendableなのでBoxも暗黙的にSendable
struct Box<Item: Sendable> {
    var item: Item
}

// Itemに指定はないのでBox2は暗黙的にSendableしない
struct Box2<Item> {
    var item: Item
}

// 明示的にSendableに準拠させる
extension Box2: Sendable where Item: Sendable {}

// finalで不変のストアドプロパティのクラスのみコンパイルがSendableに準拠できるかどうかをチェックできる
final class MyClass: Sendable {
    let name: String
    init(name: String) {
        self.name = name
    }
}

// コンパイルがSendable準拠できるかのチェックをさせない場合は@uncheckedを指定する
class MyClass2: @unchecked Sendable {}

actor SomeActor {
    func doThing(string: NSMutableString) async -> NSMutableString {
        return string
    }
}

func someFunc(actor: SomeActor, string: NSMutableString) async {
    let result = await actor.doThing(string: string)
    print(result)
}

let actor = SomeActor()
let string = NSMutableString(string: "appleapple")
Task {
    await someFunc(actor: actor, string: string)
}


/// @Sendable
@Sendable
func someFunc(_ name: String) -> String {
    return name
}
let closure: (@Sendable (String) -> Void) = { name in }

class NonSendable {
    var name: String = ""
}
var nonSendable = NonSendable()
Task {
    nonSendable.name = "apple"
}

Task {
    await withTaskGroup(of: String.self) { group in
        let non = NonSendable()
        var nsString = NSMutableString()
        var name: String = ""
        group.addTask { [name] in 
            non.name = "apple"
            //nsString = "sss"
           // name = "apple"
            return ""
        }
    }
}


//: [Next](@next)
