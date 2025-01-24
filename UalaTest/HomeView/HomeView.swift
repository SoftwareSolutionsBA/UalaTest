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
        Text("Cities")
    }
}

#Preview {
    HomeView()
}
