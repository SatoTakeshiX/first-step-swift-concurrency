//
//  ContentView.swift
//  SendableSample
//
//  Created by satoutakeshi on 2022/03/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello")
    }
}

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

/// @Sendable
@Sendable
func someFunc(_ name: String) -> String {
    return name
}
let closure: (@Sendable (String) -> Void) = { name in  }

class NonSendable {
    var name: String = ""
}
var nonSendable = NonSendable()


 // @Sendableに違反しているコード。コンパイルエラーになる
 func nestedFunc() {
     var state: Int = 42
     let closure: (@Sendable (Int) -> Void) = { new in print(state) }
     closure(1)

     class NestA {
         var nsString: NSString = "apple"
     }

     let nestA = NestA()
     @Sendable
     func updateLocalState(number: Int) {
         state += number
         nestA.nsString = "banana"
     }
 }
 
