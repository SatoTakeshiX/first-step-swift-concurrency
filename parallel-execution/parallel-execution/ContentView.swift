//
//  ContentView.swift
//  parallel-execution
//
//  Created by satoutakeshi on 2022/01/23.
//

import SwiftUI

struct ContentView: View {
    let viewModel: ContentViewModel = ContentViewModel()
    var body: some View {
        NavigationView {
            List {
                Button {
                    Task.detached {
                        await viewModel.runAsSequence()
                    }
                } label: {
                    Text("順次実行")
                }
                Button {
                    Task.detached {
                        _ = await viewModel.runAsParallel()
                    }
                } label: {
                    Text("並列実行")
                }
                Button {
                    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
                    Task {
                        for await notification in NotificationCenter.default.notifications(
                                named: UIDevice.orientationDidChangeNotification)
                                .filter({ _ in
                                    return UIDevice.current.orientation == .portrait
                                })
                        {
                            print("Device is now in portrait orientation.")
                        }
                    }

                } label: {
                    Text("通知")
                }

            }
            .navigationTitle("並列実行")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
.previewInterfaceOrientation(.portrait)
    }
}

final class ContentViewModel {

    func runAsSequence() {
        let start = Date()
        waitOneSecond {
            waitOneSecond() {
                waitOneSecond {
                    let end = Date()
                    let span = end.timeIntervalSince(start)
                    print("\(span)秒経過")
                }
            }
        }
    }

    func runAsSequence() async {
        let start = Date()
        await waitOneSecond()
        await waitOneSecond()
        await waitOneSecond()
        let end = Date()
        let span = end.timeIntervalSince(start)
        print("\(span)秒経過")
    }

    func funAsParallel(completionHandler: @escaping (() -> Void)) {
        let group: DispatchGroup = .init()
        group.enter()
        waitOneSecond {
            group.leave()
        }

        group.enter()
        waitOneSecond {
            group.leave()
        }

        group.enter()
        waitOneSecond {
            group.leave()
        }

        group.notify(queue: .global()) {
            completionHandler()
        }
    }

    func runAsParallel() async {
        let start = Date()

        async let first: Void = waitOneSecond()
        async let second: Void = waitOneSecond()
        async let third: Void = waitOneSecond()

        await first
        await second
        await third

        let end = Date()
        let span = end.timeIntervalSince(start)
        print("\(span)秒経過")
    }

    func fetchImages() async -> [UIImage] {
        async let image1 = fetchImage(userID: "1")
        async let image2 = fetchImage(userID: "2")
        async let image3 = fetchImage(userID: "3")

        return await [image1, image2, image3]
    }

    private func waitOneSecond(completionHanlder: (() -> ())) {
        sleep(1)
        completionHanlder()
    }

    private func waitOneSecond() async {
        try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)  // 1秒待つ
    }

    private func fetchImage(userID: String) async -> UIImage {
        try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)  // 1秒待つ
        return UIImage()
    }
}
