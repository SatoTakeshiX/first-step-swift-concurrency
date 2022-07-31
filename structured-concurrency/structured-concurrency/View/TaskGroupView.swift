//
//  TaskGroupView.swift
//  structured-concurrency
//
//  Created by satoutakeshi on 2022/01/29.
//

// UIImageがSendableに準拠していないのにwithTaskGroupで利用しているため
// @preconcurrencyを付与する
@preconcurrency import SwiftUI

@MainActor
struct TaskGroupView: View {
    private let viewModel: TaskGroupViewModel

    init() {
        self.viewModel = TaskGroupViewModel()
    }

    var body: some View {
        List {
            Section("Task Group使い方"){
                Button {
                    viewModel.showMypageData()
                } label: {
                    Text("２つのAPIからデータを作る")
                }
                Button {
                    viewModel.showFriendsAvators()
                } label: {
                    Text("動的な数の並列処理を行う")
                }
                Button {
                    viewModel.showAllFriends()
                } label: {
                    Text("エラーが起こる場合")
                }
                Button {
                    viewModel.showNonHandlingCancel()
                } label: {
                    Text("キャンセルチェックしない場合")
                }
                Button {
                    viewModel.showSendLogs()
                } label: {
                    Text("Voidでgroupの結果使わない")
                }
            }
        }
    }
}

@MainActor
final class TaskGroupViewModel {

    struct MypageInfo {
        let friends: [String]
        let airticleTitles: [String]
    }

    struct InternalError: Error {}

    func showNonHandlingCancel() {
        Task {
            await TimeTracker.track {
                try? await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask {
                        try Task.checkCancellation()
                        await Task.sleep(NSEC_PER_SEC)
                        try Task.checkCancellation()
                        await Task.sleep(NSEC_PER_SEC)
                        try Task.checkCancellation()
                        await Task.sleep(NSEC_PER_SEC)
                        try Task.checkCancellation()
                    }

                    group.addTask {
                        try Task.checkCancellation()
                        await Task.sleep(NSEC_PER_SEC)
                        try Task.checkCancellation()
                    }
                    let _ = try await group.next()
                    group.cancelAll()
                }
            }
        }
    }

    func showMypageData() {
        Task {
            await TimeTracker.track {
                let mypageData = await fetchMyPageData()
                print(mypageData)
            }
        }
    }

    func showFriendsAvators() {
        Task {
            await TimeTracker.track {
                let avators = await fetchFriendsAvators(ids: ["1", "2", "3"])
                print(avators)
            }
        }
    }

    func showAllFriends() {
        Task {
            await TimeTracker.track {
                do {
                    let friends = try await fetchAllFriends()
                    print(friends)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func showSendLogs() {
        Task {
            await sendLog()
            print("finish \(#function)")
        }

    }

    /// 架空のSNSアプリのマイページでデータを取得するメソッド
    /// ２つのAPIから必要なデータ、MypageInfoを組み立てる
    func fetchMyPageData() async -> MypageInfo {

        var friends: [String] = []
        var articles: [String] = []

        enum FetchType {
            case friends([String])
            case articles([String])
        }
        await withTaskGroup(of: FetchType.self) { group in

            /**
             TaskGroup.addTaskのクロージャー内のself参照について
             https://github.com/apple/swift-evolution/blob/main/proposals/0304-structured-concurrency.md#implicit-self
             TaskGroup.addTaskのクロージャーはすぐに実行され、実行完了後はクロージャーは開放されるのでselfとの循環参照の恐れがない。
             よって[weak self]でselfを弱参照する必要なし。そのまま`self.`でselfのメソッドにアクセスしてよい。
             */
            group.addTask {
                // 友達APIを叩いて名前を取得
                // 3秒かかる
                let friends = await self.fetchFriends()
                return FetchType.friends(friends)
            }

            group.addTask {
                // 投稿記事APIを叩いて記事名を取得
                // 1秒かかる
                let articles = await self.fetchArticles()
                return FetchType.articles(articles)
            }

            for await fetchResult in group {
                switch fetchResult {
                    case .friends(let f):
                        friends = f
                    case .articles(let a):
                        articles = a
                }
            }

//            // 2つの子タスクのうち最初に終わったタスク結果を得る
//            guard let firstResult = await group.next() else {
//                group.cancelAll()
//                return
//            }
//            switch firstResult {
//                case .articles(let a):
//                    articles = a
//                case .friends(let f):
//                    friends = f
//            }
//            // 2番目に終わった結果を得る
//            guard let secondResult = await group.next() else {
//                group.cancelAll()
//                return
//            }
//            switch secondResult {
//                case .articles(let a):
//                    articles = a
//                case .friends(let f):
//                    friends = f
//            }
        }

        return MypageInfo(friends: friends,
                          airticleTitles: articles)
    }

    func fetchFriendsAvators(ids: [String]) async -> [String: UIImage?] {
        return await withTaskGroup(of: (String, UIImage?).self) { group in
            for id in ids {
                group.addTask {
                    return (id, await self.fetchAvatorImage(id: id))
                }
            }
            var avators: [String: UIImage?] = [:]
            for await (id, image) in group {
                avators[id] = image
            }
            return avators
        }
    }

    func fetchAllFriends() async throws -> [String] {
        return try await withThrowingTaskGroup(of: [String].self) { group in
            group.addTask {
                // 3秒かかる
                return await self.fetchFriends()
            }

            group.addTask {
                // 1秒かかる
                // エラーが発生する
                return try await self.fetchFriendsFromLocalDB()
            }

            var allFriends: [String] = []
            // fetchFriendsFromLocalDBのエラーが親タスクのfetchAllFriendsにも伝播する
            for try await friends in group {
                allFriends.append(contentsOf: friends)
            }

            return allFriends
        }
    }

    func sendLog() async {
        return await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await Util.wait(seconds: 1)
                print("finish \(#function)")
            }
        }
    }
}

extension TaskGroupViewModel {

    /// フォローしている友達の名前を取得する。3秒かかる処理
    /// - Returns: 友達の名前の配列
    private func fetchFriends() async -> [String] {
        await Util.wait(seconds: 3)
        return [
            "Aris",
            "Bob",
            "Cooper",
            "David"
        ]
    }

    /// 投稿記事のタイトルを取得する。1秒かかる処理
    /// - Returns: 記事のタイトルの配列
    private func fetchArticles() async -> [String] {
        await Util.wait(seconds: 1)
        return [
            "猫を飼い始めました",
            "名前はココア",
            "仕事の邪魔をするココア"
        ]
    }

    private func fetchAvatorImage(id: String) async -> UIImage {
        await Util.wait(seconds: 2)
        return UIImage()
    }

    private func fetchFriendsFromLocalDB() async throws -> [String] {
        await Util.wait(seconds: 1)
        throw InternalError()
    }
}

struct TaskGroupView_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroupView()
    }
}
