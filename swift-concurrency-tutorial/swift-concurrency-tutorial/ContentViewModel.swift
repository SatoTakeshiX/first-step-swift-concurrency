//
//  ContentViewModel.swift
//  swift-concurrency-tutorial
//
//  Created by satoutakeshi on 2022/01/05.
//

import Foundation
import SwiftUI

final class ContentViewModel {
    func request() {
        let task = URLSession.shared.dataTask(with: URLRequest(url: URL(fileURLWithPath: ""))) { data, respones, error in

        }
    }
}
