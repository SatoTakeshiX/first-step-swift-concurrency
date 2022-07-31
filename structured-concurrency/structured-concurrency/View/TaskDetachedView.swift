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
                Button {
                    viewModel.cancelParentTask()
                } label: {
                    Text("下位階層にStructured Concurrencyがある場合")
                }
            }
        }
    }
}

@MainActor
final class TaskDetachedViewModel {

    var parentTask: Task<Void, Never>?

    func didTapButton() {
        Task {
            // ログを送信
            Task.detached(priority: .low) {
                // Task.detachedのクロージャー内のself参照について
                // https://github.com/apple/swift-evolution/blob/main/proposals/0304-structured-concurrency.md#implicit-self
                // Task.detachedはすぐに実行され、実行完了後はクロージャーは開放されるのでselfとの循環参照の恐れがない。
                // よって[weak self]でselfを弱参照する必要なし。そのまま`self.`でselfのメソッドにアクセスしてよい。
                print("detached isMainThread: \(Thread.isMainThread)")
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

    func cancelParentTask() {
        Task {
            await TimeTracker.track {
                parentTask = Task.detached {
                    await withTaskGroup(of: Void.self) { group in
                        group.addTask {
                            try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
                        }
                        for await _ in group {
                            print("finish withTaskGroup")
                        }
                    }

                    async let sleep2seconds: ()? = try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
                    await sleep2seconds
                    print("finish async let")
                }
                parentTask?.cancel()
            }
        }
    }
}

struct TaskDetached_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetachedView()
    }
}
