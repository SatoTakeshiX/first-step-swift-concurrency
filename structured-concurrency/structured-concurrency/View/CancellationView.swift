//
//  CancellationView.swift
//  structured-concurrency
//
//  Created by satoutakeshi on 2022/05/08.
//

@preconcurrency import SwiftUI

struct CancellationView: View {
    let viewModel = CancellationViewModel()
    var body: some View {
        List {
            Button {
                Task {
                    await TimeTracker.track {
                        do {
                            _ = try await viewModel.fetchDataWithLongTask()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            } label: {
                Text("Task.checkCancellation")
            }
            Button {
                viewModel.showNonHandlingCancel()
            } label: {
                Text("キャンセルチェックしない場合")
            }
            Button {
                viewModel.showHandlingCancel()
            } label: {
                Text("キャンセルチェックする場合")
            }
        }
    }
}

final class CancellationViewModel: @unchecked Sendable {

//    func taskGroupCancel() async throws -> [String] {
//        return await withThrowingTaskGroup(of: [String].self) { group in
//
//            group.addTask {
//                try Task.checkCancellation()
//                await Task.sleep(1 * NSEC_PER_SEC)
//                return ["a", "b"]
//            }
//
//            group.cancelAll()
//            //let firstResult = try await group.next()
//
//            return []
//        }
//    }

    func fetchDataWithLongTask() async throws -> [String] {
        return await withThrowingTaskGroup(of: [String].self) { group in

            group.addTask {
                try Task.checkCancellation()
                await self.veryLongTask()
                return ["a", "b"]
            }

            group.cancelAll()
            return []
        }
    }

    func veryLongTask() async {
        await Task.sleep(1 * NSEC_PER_SEC)
    }

    func fetchIconsWithLongTask(ids: [String]) async throws -> [UIImage] {
        return try await withThrowingTaskGroup(of: UIImage.self) { group in
            for id in ids {
                if Task.isCancelled { break }
                group.addTask {
                    return await self.fetchImage(with: id)
                }
            }
            var icons: [UIImage] = []
            for try await image in group {
                icons.append(image)
            }
            return icons
        }
    }

    func fetchImage(with id: String) async -> UIImage {
        try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
        return UIImage()
    }

    func showNonHandlingCancel() {
        Task {
            await TimeTracker.track {
                await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask {
                        // 3秒待つ
                        // Task.sleepはキャンセル、エラーが起きても実際にキャンセルはされない
                        await Task.sleep(NSEC_PER_SEC * 3)
                    }
                    group.cancelAll()
                }
            }
        }
    }

    func showHandlingCancel() {
        Task {
            await TimeTracker.track {
                await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask {
                        // キャンセルをチェック
                        try Task.checkCancellation()
                        // 3秒待つ
                        await Task.sleep(NSEC_PER_SEC * 3)
                    }
                    group.cancelAll()
                }
            }
        }
    }
}

struct CancellationView_Previews: PreviewProvider {
    static var previews: some View {
        CancellationView()
    }
}
