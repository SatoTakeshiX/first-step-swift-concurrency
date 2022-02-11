//
//  TaskView.swift
//  structured-concurrency
//
//  Created by satoutakeshi on 2022/02/04.
//

import SwiftUI

struct TaskView: View {
    private var viewModel = TaskViewModel()

    var body: some View {

        VStack {
            List {
                Section("Taskでキャンセル"){
                    Button {
                        viewModel.fetchUser()
                    } label: {
                        Text("長い処理")
                    }
                    Button {
                        viewModel.fetchUserWithCheckCancellation()
                    } label: {
                        Text("長い処理でエラー起きる：checkCancellationを使う")
                            .lineLimit(nil)
                    }

                    Button {
                        viewModel.fetchUserWithIsCancelled()
                    } label: {
                        Text("長い処理でエラー起きる：isCancelledを使う")
                    }
                }
            }
            Button {
                viewModel.forceCancel()
            } label: {
                Text("forceCancel")
            }
            .padding()
        }
    }
}

final class TaskViewModel {

    struct InternalError: Error {}

    private(set) var message: String = ""

    var task: Task<(), Never>? = nil
    func fetchUser() {
        task = Task {
            let users = await longTask()
            print(users)
        }
    }

    func fetchUserWithCheckCancellation() {
        task = Task {
            do {
                let users = try await longTaskWithError()
                print(users)
            } catch is CancellationError {
                print("キャンセルされた")
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func fetchUserWithIsCancelled() {
        task = Task {
            do {
                let users = try await longTaskWithManualCancelError()
                print(users)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func forceCancel() {
        guard let task = task else { return }
        task.cancel()
    }

    func longTask() async -> [String] {
        await Util.wait(seconds: 3)
        return [
            "Aris",
            "Bob",
            "Cooper",
            "David"
        ]
    }

    func longTaskWithError() async throws -> [String] {
        await Util.wait(seconds: 3)
        try Task.checkCancellation()
        throw InternalError()
    }

    func longTaskWithManualCancelError() async throws -> [String] {
        await Util.wait(seconds: 3)
        if Task.isCancelled {
            print("manual cancel")
            throw CancellationError()
        } else {
            throw InternalError()
        }
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView()
    }
}

actor A {
    func runTask() {
        Task(priority: .high) {
            Task {
                // 子タスクはpriority: highを引き継ぐ
            }
        }
    }
}
