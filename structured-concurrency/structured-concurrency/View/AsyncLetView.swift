//
//  AsyncLetView.swift
//  structured-concurrency
//
//  Created by satoutakeshi on 2022/02/01.
//

import SwiftUI

@MainActor
struct AsyncLetView: View {
    private let viewModel: AsyncLetViewModel

    init() {
        self.viewModel = AsyncLetViewModel()
    }

    var body: some View {
        List {
            Section("async let使い方"){
                Button {
                   viewModel.showMypageData()
                } label: {
                    Text("並列処理")
                }
                Button {
                   viewModel.showAllFriends()
                } label: {
                    Text("エラーが起こる場合")
                }
                Button {
                   viewModel.runVoid()
                } label: {
                    Text("戻り値がない関数")
                }
                Button {
                   viewModel.noMarkAwait()
                } label: {
                    Text("awaitを呼ばないと？")
                }
            }
        }
    }
}

@MainActor
final class AsyncLetViewModel {

    struct MypageInfo {
        let friends: [String]
        let airticleTitles: [String]
    }

    struct InternalError: Error {}

    func showMypageData() {
        Task {
            let mypageData = await fetchMyPageData()
            print(mypageData)
        }
    }

    func showAllFriends() {
        Task {
            await TimeTracker.track {
                do {
                    let allFriends = try await fetchAllFriends()
                    print(allFriends)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func runVoid() {
        Task {
            async let result1: Void = sendLogs()
            async let result2: Void = sendLogs()
            await result1
            await result2
        }
    }

    func noMarkAwait() {
        Task {
            await TimeTracker.track {
                async let friends = fetchFriends()
                async let articles = fetchArticles()
                // 変数をawaitしないとすぐにリターンされる
            }
        }
    }

    /// 架空のSNSアプリのマイページでデータを取得するメソッド
    /// ２つのAPIから必要なデータ、MypageInfoを組み立てる
    func fetchMyPageData() async -> MypageInfo {

        async let friends = fetchFriends()
        async let articles = fetchArticles()

        return await MypageInfo(friends: friends,
                                airticleTitles: articles)
    }

    func fetchAllFriends() async throws -> [String] {
        async let friends = fetchFriends() // 3秒かかる
        async let localFriends = fetchFriendsFromLocalDB() // 1秒でエラー返す
        return try await localFriends + friends
    }

}

extension AsyncLetViewModel {
    private func fetchFriends() async -> [String] {
        // エラー発生で
        await Util.wait(seconds: 3)
        return [
            "Aris",
            "Bob",
            "Cooper",
            "David"
        ]
    }

    private func fetchArticles() async -> [String] {
        await Util.wait(seconds: 1)
        return [
            "猫を飼い始めました",
            "名前はココア",
            "仕事の邪魔をするココア"
        ]
    }

    private func fetchFriendsFromLocalDB() async throws -> [String] {
        await Util.wait(seconds: 1)
        throw InternalError()
    }

    private func sendLogs() async {
        await Util.wait(seconds: 1)
    }
}


struct AsyncLet_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLetView()
    }
}
