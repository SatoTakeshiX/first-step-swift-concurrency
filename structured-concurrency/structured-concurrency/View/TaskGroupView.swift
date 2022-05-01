//
//  TaskGroupView.swift
//  structured-concurrency
//
//  Created by satoutakeshi on 2022/01/29.
//

import SwiftUI

struct TaskGroupView: View {
    private let viewModel = TaskGroupViewModel()
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
                    viewModel.showSendLogs()
                } label: {
                    Text("Voidでgroupの結果使わない")
                }
            }
        }
    }
}

final class TaskGroupViewModel {

    struct MypageInfo {
        let friends: [String]
        let airticleTitles: [String]
    }

    struct InternalError: Error {}

    func showMypageData() {
        Task {
            await TimeTracker.track { [weak self] in
                guard let self = self else { return }
                let mypageData = await self.fetchMyPageData()
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

            group.addTask { [weak self] in
                // 友達APIを叩いて名前を取得
                let friends = await self?.fetchFriends() ?? []
                //name = "apple"
                return FetchType.friends(friends)
            }

            group.addTask { [weak self] in
                // 投稿記事APIを叩いて記事名を取得
                let articles = await self?.fetchArticle() ?? []
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
                group.addTask { [weak self] in
                    return (id, await self?.fetchAvatorImage(id: id))
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
            group.addTask { [weak self] in
                guard let self = self else { throw InternalError() }
                // 3秒かかる
                return await self.fetchFriends()
            }

            group.addTask { [weak self] in
                guard let self = self else { throw InternalError() }
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

    private func fetchFriends() async -> [String] {
        await Util.wait(seconds: 2)
        return [
            "Aris",
            "Bob",
            "Cooper",
            "David"
        ]
    }

    private func fetchArticle() async -> [String] {
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
