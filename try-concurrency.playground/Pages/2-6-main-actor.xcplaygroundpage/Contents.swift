//: [Previous](@previous)

import SwiftUI
import _Concurrency
import PlaygroundSupport

// 型全体に適応
@MainActor
class UserDataSource {
    // 暗黙的にMainActorが適応されている
    var user: String = ""
    // 暗黙的にMainActorが適応されている
    func updateUser() {}
    // nonisolatedでMainActorを解除する
    nonisolated func sendLogs() {}
}

struct Mypage {
    // プロパティに適応
    @MainActor
    var info: String = ""

    // メソッドに適応
    @MainActor
    func updateInfo() {}

    // MainActorは適応されない
    func sendLogs() {}
}

struct ContentView: View {
    @StateObject
    private var viewModel: ViewModel

    init() {
        _viewModel = StateObject(wrappedValue: ViewModel())
    }

    var body: some View {
        List {
            Text(viewModel.text)
            Button {
                viewModel.didTapButton()
            } label: {
                Text("text更新")
            }
        }
    }
}

@MainActor
final class ViewModel: ObservableObject {
    @Published
    private(set) var text: String = ""

    /*
    nonisolated func fetchUser() async {
        // Property 'text' isolated to global actor
        // 'MainActor' can not be mutated from a non-isolated context
        text = await waitOneSecond(with: "arex")
    }
    */

    nonisolated func fetchUser() async -> String {
        return await waitOneSecond(with: "Arex")
    }

    func didTapButton() {
        Task {
            text = ""
            text = await fetchUser()
        }
    }

    private func waitOneSecond(with string: String) async -> String {
        try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)  // 1秒待つ
        return string
    }
}

PlaygroundPage.current.setLiveView(ContentView())

//: [Next](@next)
