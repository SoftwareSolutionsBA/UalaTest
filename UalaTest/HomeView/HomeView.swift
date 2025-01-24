//
//  ContentView.swift
//  UalaTest
//
//  Created by David Figueroa on 22/01/25.
//

import SwiftUI

struct HomeView: View {

    @StateObject var viewModel: HomeViewModel = HomeViewModel()

    var body: some View {
        VStack {
            if viewModel.loadingData {
                ProgressView(label: { Text("Loading...") })
            }

            Text("Cities")
                .onAppear { viewModel.fetchItems() }

            Button {

            } label: {
                Text("test")
            }

        }
    }
}

#Preview {
    HomeView()
}
