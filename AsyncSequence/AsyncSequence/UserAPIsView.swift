//
//  UserAPIsView.swift
//  AsyncSequence
//
//  Created by satoutakeshi on 2022/03/06.
//

import SwiftUI

struct UserAPIsView: View {
    @StateObject
    private var  viewModel: UserAPIsViewModel

    init() {
        self._viewModel = StateObject(wrappedValue: UserAPIsViewModel())
    }

    var body: some View {
        VStack {
            TextEditor(text: $viewModel.text)
                .frame(height: 300)
            Button {
                viewModel.readText()
            } label: {
                Text("ファイル読み込み")
            }

        }
        .navigationTitle("APIを使う")
        .onAppear {
            viewModel.checkAppStatus()

        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
}

@MainActor
final class UserAPIsViewModel: ObservableObject {

    @Published
    var text: String = ""

    var enterForegroundTask: Task<Void, Never>?
    var enterBackgroundTask: Task<Void, Never>?

    func checkAppStatus() {
        lagacyObserve()
        let notificationCenter = NotificationCenter.default
        enterForegroundTask = Task {
            let willEnterForeground = notificationCenter.notifications(named: UIApplication.willEnterForegroundNotification)

            for await notification in willEnterForeground {
                print(notification)
            }
        }

        enterBackgroundTask = Task {
            let didEnterBackground = notificationCenter.notifications(named: UIApplication.didEnterBackgroundNotification)

            for await notification in didEnterBackground {
                print(notification)
            }
        }
    }

    func lagacyObserve() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                       object: nil, queue: nil) { notification in
            print("\(notification)")
        }
    }

    func readText() {
        Task {
            text = ""
            guard let url = Bundle.main.url(forResource: "text", withExtension: "txt") else {
                return
            }
            do {
                for try await line in url.lines {
                    print(line)
                    if line == "apple" {
                        continue
                    }

                    if line == "five" {
                        break
                    }
                    text += "\(line)\n"
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func cleanup() {
        enterForegroundTask?.cancel()
        enterBackgroundTask?.cancel()
    }
}

struct UserAPIsView_Previews: PreviewProvider {
    static var previews: some View {
        UserAPIsView()
    }
}
