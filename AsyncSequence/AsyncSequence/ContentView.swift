//
//  ContentView.swift
//  AsyncSequence
//
//  Created by satoutakeshi on 2022/03/06.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("APIを使う") {
                    UserAPIsView()
                }

                NavigationLink("自分で作る") {
                    CustomeAsyncSequence()
                }

                NavigationLink("AsyncSteam") {
                    AsyncStreamView()
                }

            }
            .listStyle(.insetGrouped)
            .navigationTitle("AsyncSequence")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
