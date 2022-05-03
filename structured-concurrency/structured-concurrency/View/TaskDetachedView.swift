//
//  TaskDetached.swift
//  structured-concurrency
//
//  Created by satoutakeshi on 2022/02/11.
//

import SwiftUI

@MainActor
struct TaskDetachedView: View {
    private var viewModel: TaskDetachedViewModel

    init() {
        self.viewModel = TaskDetachedViewModel()
    }

    var body: some View {
        List {
            Section("Task.detached"){
                Button {
                    viewModel.didTapButton()
                } label: {
                    Text("ログを送りつつfetch処理")
                }
            }
        }
    }
}

@MainActor
final class TaskDetachedViewModel {
    func didTapButton() {
        Task {
            // ログを送信
            Task.detached(priority: .low) { [weak self] in
                print("detached isMainThread: \(Thread.isMainThread)")
                guard let self = self else { return }
                async let _ = await self.sendLog(name: "didTapButton")
                async let _ = await self.sendLog(name: "user is xxx")
            }
            Task {
                // MainActor引き継ぐ
            }
        }
    }

    private func fetchUser() async -> [String] {
        await Util.wait(seconds: 3)
        print("fetchUser isMainThread: \(Thread.isMainThread)")
        return [
            "Aris",
            "Bob",
            "Cooper",
            "David"
        ]
    }

    private func sendLog(name: String) async {
        print("sending with \(name)")
    }

}

struct TaskDetached_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetachedView()
    }
}
