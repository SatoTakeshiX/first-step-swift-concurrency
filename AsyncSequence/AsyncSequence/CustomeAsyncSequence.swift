//
//  CustomeAsyncSequence.swift
//  AsyncSequence
//
//  Created by satoutakeshi on 2022/03/06.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct CustomeAsyncSequence: View {
    @State
    private var task: Task<Void, Never>?

    @StateObject
    private var filterManager: FilterImageManeger

    init() {
        self._filterManager = StateObject(wrappedValue: FilterImageManeger())
    }

    var body: some View {
        List {
            Button {
                task = Task {
                    let counter = Counter()
                    for await i in counter.countdown(amount: 10) {
                        print(i)
                    }

                    let firstEven = await counter.countdown(amount: 10).first { $0 % 2 == 0 }
                    print(firstEven ?? "なし")
                }
            } label: {
                Text("カウントダウン")
            }
            Button {
                filterManager.showFilteredImages(image: UIImage(named: "mac")!)
            } label: {
                Text("画像フィルター開始")
            }
            ForEach(filterManager.images, id: \.self) { image in
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .navigationTitle("自分で作る")
        .onDisappear {
            task?.cancel()
        }
    }
}

struct Counter {
    struct AsyncCounter: AsyncSequence {
        typealias Element = Int
        let amount: Int

        struct AsyncIterator: AsyncIteratorProtocol {
            var amount: Int
            mutating func next() async -> Element? {

                guard amount >= 0 else {
                    return nil
                }

                let result = amount
                amount -= 1
                return result
            }
        }

        func makeAsyncIterator() -> AsyncIterator {
            return AsyncIterator(amount: amount)
        }
    }

    func countdown(amount: Int) -> AsyncCounter {
        return AsyncCounter(amount: amount)
    }
}

@MainActor
final class FilterImageManeger: ObservableObject {
    struct ImageFilter: AsyncSequence {
        typealias Element = UIImage
        let image: UIImage

        struct AsyncIterator: AsyncIteratorProtocol {
            var counter = 2
            let image: UIImage
            mutating func next() async -> Element? {
                guard counter >= 0 else {
                    return nil
                }

                let filteredImage: UIImage?
                if counter == 2 {
                    filteredImage = filter(inputImage: image, filterHandler: makePixellateFilter)
                } else if counter == 1 {
                    filteredImage = filter(inputImage: image, filterHandler: makeSepiaTone)
                } else {
                    filteredImage = nil
                }

                counter -= 1

                return filteredImage
            }

            func filter(inputImage: UIImage, filterHandler: ((CIImage?) -> CIFilterProtocol) ) -> UIImage? {
                let beginImage = CIImage(image: inputImage)
                let context = CIContext()
                let currentFilter = filterHandler(beginImage)

                // get a CIImage from our filter or exit if that fails
                guard let outputImage = currentFilter.outputImage else { return nil }

                // attempt to get a CGImage from our CIImage
                if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                    // convert that to a UIImage
                    return UIImage(cgImage: cgimg, scale: 0, orientation: inputImage.imageOrientation)
                } else {
                    return nil
                }
            }

            func makePixellateFilter(inputImage: CIImage?) -> CIFilterProtocol {
                let currentFilter = CIFilter.pixellate()
                currentFilter.inputImage = inputImage
                currentFilter.scale = 40
                return currentFilter
            }

            func makeSepiaTone(inputImage: CIImage?) -> CIFilterProtocol {
                let currentFilter = CIFilter.sepiaTone()
                currentFilter.inputImage = inputImage
                currentFilter.intensity = 1
                return currentFilter
            }
        }
        func makeAsyncIterator() -> AsyncIterator {
            return AsyncIterator(image: image)
        }
    }

    @Published
    var images: [UIImage] = []
    nonisolated func filterImage(image: UIImage) async -> [UIImage] {

        let task = Task.detached(priority: .low) { () -> [UIImage] in
            var images: [UIImage] = []
            for await image in ImageFilter(image: image) {
                images.append(image)
            }
            return images
        }

        return await task.value
    }

    func showFilteredImages(image: UIImage) {
        Task(priority: .low) {

            images = await filterImage(image: image)
        }
    }
}

struct CustomeAsyncSequence_Previews: PreviewProvider {
    static var previews: some View {
        CustomeAsyncSequence()
    }
}
