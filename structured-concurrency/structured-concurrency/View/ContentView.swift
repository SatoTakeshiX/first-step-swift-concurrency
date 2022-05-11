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
                        AsyncLetView()
                    }
                }

                Section("unstructured concurrency") {
                    NavigationLink("Task") {
                        TaskView()
                    }
                    NavigationLink("Task.detached") {
                        TaskDetachedView()
                    }
                }

                Section("Cancel Check") {
                    NavigationLink("Cancel Check") {
                        CancellationView()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Task List")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

final class ContentViewModel: ObservableObject {

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
