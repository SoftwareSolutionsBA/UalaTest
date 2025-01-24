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
            VStack(alignment: .leading) {
                HStack {
                    Text("Filters")
                        .fontWeight(.bold)
                    Spacer()
                }

                TextField(text: $viewModel.searchText, label: { Text("Filter by City Name...") })
                    .frame(maxWidth: 200)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.blue, lineWidth: 1)
                    )

                HStack {
                    Button {
                        print("Show Favorites")
                    } label: {
                        HStack {
                            Text("Show Only Favorites")
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: 16, height: 16, alignment: .center)
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.blue, lineWidth: 1)
                        )
                    }
                    Spacer()
                }
            }
            .padding(.vertical)

            if viewModel.loadingData {
                ProgressView(label: { Text("Fetching Data...").bold() })
            }

            if viewModel.notFound {
                Text("NOT FOUND").bold()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(viewModel.displayedCities, id: \.self) { city in
                            CellView(city: city.name, country: city.country)
                        }
                    }
                }
            }
            
            Spacer()

        }
        .padding(16)
        .onAppear { viewModel.fetchItems() }
    }
}

#Preview {
    HomeView()
}
