//
//  ContentView.swift
//  structured-concurrency
//
//  Created by satoutakeshi on 2022/01/29.
//

import SwiftUI

struct ContentView: View {
    @StateObject
    private var viewModel = ContentViewModel()

    var body: some View {

        NavigationView {
            List {
                Section("structured concurrency") {
                    NavigationLink("Task Group") {
                        TaskGroupView()
                    }
                    NavigationLink("async let") {

                    }
                }

                Section("unstructured concurrency") {
                    NavigationLink("Task") {

                    }
                    NavigationLink("Task.detached") {

                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Task List")
        }

    }
}

final class ContentViewModel: ObservableObject {

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
