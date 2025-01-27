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
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.33555555, longitude: -122.0091666), // APPLE HEADQUARTERS
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var isPortrait: Bool = true

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                HStack {
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

                    if !isPortrait{
                        Map(coordinateRegion: $region)
                            .cornerRadius(10)
                            .padding(5)
                    }
                }
                .onChange(of: geometry.size) { newSize in
                    isPortrait = newSize.height > newSize.width
                }
                .onAppear {
                    isPortrait = geometry.size.height > geometry.size.width
                }
            }
        }
    }

    private var itemsList: some View {
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

    @ViewBuilder
    func mapView(in region: MKCoordinateRegion) -> some View {
        Map(coordinateRegion: .constant(region))
            .cornerRadius(10)
            .padding(5)
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
                    Text("Favorite").font(.caption)
                    Image(systemName: city.wrappedValue.isFavorite ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 16, height: 16, alignment: .center)
                }
                .padding()
            }
            .frame(height: 30)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.blue, lineWidth: 1)
            )
            .padding(.top, 10)

            NavigationLink {
                mapView(in: MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: city.wrappedValue.coordinates.lat, longitude: city.wrappedValue.coordinates.lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                ))
            } label: {
                HStack {
                    Text("Show in Map").font(.caption)
                    Image(systemName: "mappin")
                        .resizable()
                        .frame(width: 10, height: 16, alignment: .center)
                }
                .padding()
                .frame(height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue, lineWidth: 1)
                )
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
