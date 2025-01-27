//
//  ContentView.swift
//  UalaTest
//
//  Created by David Figueroa on 22/01/25.
//

import SwiftUI
import MapKit

struct HomeView: View {

    @StateObject var viewModel: HomeViewModel = HomeViewModel()
    @State var showFavorites = false

    var body: some View {
        VStack {
            filtersSection
                .padding(.vertical)

            if viewModel.loadingData {
                ProgressView(label: { Text("Fetching Data...").bold() })
            }

            if viewModel.notFound {
                Text("NOT FOUND").bold()
            } else {
                HStack {
                    itemsList
                        .frame(maxWidth: 300, alignment: .leading)
                    Spacer()
                }
            }

            Spacer()
        }
        .padding(16)
        .onAppear { viewModel.fetchItems() }
    }

    private var itemsList: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach($viewModel.displayedCities, id: \.self) { city in
                        NavigationLink {
                            ScrollView {
                                HStack {
                                    itemView(for: city)
                                    Spacer()
                                }
                            }.padding()
                        } label: {
                            CellView(city: city.wrappedValue.name, country: city.wrappedValue.country)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    func itemView(for city: Binding<City>) -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 5) {
                Text(city.wrappedValue.name + ",").bold()
                Text(city.wrappedValue.country).italic()
            }
            Text("Lat \(city.wrappedValue.coordinates.lat)").font(.caption)
            Text("Lon \(city.wrappedValue.coordinates.lon)").font(.caption)

            Button {
                city.wrappedValue.isFavorite.toggle()
            } label: {
                HStack {
                    Text("Favorite")
                    Image(systemName: city.wrappedValue.isFavorite ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 16, height: 16, alignment: .center)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue, lineWidth: 1)
                )
                .frame(minHeight: 55)
            }
        }
        .padding(20)
        .border(.blue)
    }

    private var filtersSection: some View {

        VStack(alignment: .leading) {
            HStack {
                Text("Filters")
                    .fontWeight(.bold)
                Spacer()
            }

            ZStack(alignment: .trailing) {
                TextField(text: $viewModel.searchText, label: { Text("Filter by City Name...").font(.callout) })
                    .padding()
                    .padding(.trailing, viewModel.isFilteringItems ? 20 : 0)

                if viewModel.isFilteringItems {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .padding(.horizontal, 10)
                }
            }
            .frame(maxWidth: 230, minHeight: 55)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.blue, lineWidth: 1)
            )

            HStack {
                Button {
                    showFavorites.toggle()
                    viewModel.showOnlyFavorites(showFavorites)
                } label: {
                    HStack {
                        Text("Show Favorites")
                        Image(systemName: showFavorites ? "star.fill" : "star")
                            .resizable()
                            .frame(width: 16, height: 16, alignment: .center)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.blue, lineWidth: 1)
                    )
                    .frame(minHeight: 55)
                }

                Spacer()
            }
        }
    }
}

#Preview {
    HomeView()
}
