//: [Previous](@previous)

import Foundation
import _Concurrency

struct Counter : AsyncSequence {
    typealias Element = Int
    let howHigh: Int

    struct AsyncIterator : AsyncIteratorProtocol {
        let howHigh: Int
        var current = 1
        mutating func next() async -> Int? {
            // A genuinely asychronous implementation uses the `Task`
            // API to check for cancellation here and return early.
            guard current <= howHigh else {
                return nil
            }

            let result = current
            current += 1
            return result
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(howHigh: howHigh)
    }
}

Task {
    for await i in Counter(howHigh: 10) {
        print(i)
    }
}

// どんな例がいいかな？
/*
 URL->ファイルのlineごとになにかする
 counter
 for inでやりたいこと。
 arrayを回したいと思ったけど、Task groupの使い方はすごい
 addTaskして結果をnextで受ける。
 タスクを入れてnextで受ける。
 料理の例よさそう？並列処理で例に出ていた。

 for awai in で回すと料理が次々に出てくるとか？

 カウンターの例を出して、説明した後に、料理の

 総カロリーを入力すると、そこまで食べられる料理を出してくれるとかよさそう
 */


func observeNotifications() async {
    //Use any notification name appropriate
    let customNotificationName = Notification.Name("custom")

    let notifications = NotificationCenter.default.notifications(named: customNotificationName) //If you want to receive only notifications from a specific sender then specify that in object

    //notifications is an AsyncSequence
    //Each iteration in the loop would run asynchronously as when new notification is added to the sequence
    for await notification in notifications {
        print(notification)
    }
}

class SampleNotif: NSObject {
    func observe() {
        let nc = NotificationCenter.default

        nc.addObserver(self, selector: #selector(userLoggedIn), name: Notification.Name("UserLoggedIn"), object: nil)
    }


    @objc func userLoggedIn() {
        print("-----loggenin-----")
    }

    func post() {
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("UserLoggedIn"), object: nil)
        nc.post(name: Notification.Name("custom"), object: nil)
    }

    func observeNotifications() async {
        //Use any notification name appropriate
        let customNotificationName = Notification.Name("custom")

        let notifications = NotificationCenter.default.notifications(named: customNotificationName) //If you want to receive only notifications from a specific sender then specify that in object

        //notifications is an AsyncSequence
        //Each iteration in the loop would run asynchronously as when new notification is added to the sequence
        for await notification in notifications {
            print(notification)
        }
    }
}

let s = SampleNotif()
s.observe()
s.post()
s.post()

Task {
    await s.observeNotifications()
    s.post()

}




func postNotification() {
    let n = Notification(name: Notification.Name("custom"), object: nil, userInfo: nil)
    NotificationCenter.default.post(n)
}

Task {

    await observeNotifications()


}

postNotification()
postNotification()
postNotification()


//: [Next](@next)
