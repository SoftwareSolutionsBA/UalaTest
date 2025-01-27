//
//  HomeViewModelTests.swift
//  UalaTest
//
//  Created by David Figueroa on 27/01/25.
//

import XCTest
import CoreData
import Combine
@testable import UalaTest

class MockAPIClient: APIClientProtocol {
    func fetchCities() async -> [City] {
        let coordinates = Coordinates(lon: 10.0, lat: 20.0)

        return [
            City(country: "US", name: "New York", id: 0, coordinates: coordinates, isFavorite: true),
            City(country: "US", name: "Los Angeles", id: 1, coordinates: coordinates, isFavorite: false),
            City(country: "US", name: "Chicago", id: 2, coordinates: coordinates, isFavorite: true),
            City(country: "US", name: "Houston", id: 3, coordinates: coordinates, isFavorite: false)
        ]
    }
}

class HomeViewModelTests: XCTestCase {
    var viewModel: HomeViewModel!
    var mockAPIClient: MockAPIClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        viewModel = HomeViewModel(apiClient: mockAPIClient)
    }

    override func tearDown() {
        viewModel = nil
        mockAPIClient = nil
        super.tearDown()
    }

    func testInitialLoadingState() {
        XCTAssertEqual(viewModel.notFound, false)
        XCTAssertEqual(viewModel.isFilteringItems, false)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertEqual(viewModel.cities.count, 0)
        XCTAssertEqual(viewModel.displayedCities.count, 0)
    }

    func testFetchItems() {
        let expectation = XCTestExpectation(description: "Wait for fetchItems to complete")
        viewModel.fetchItems()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(self.viewModel.cities.count, 4)
            XCTAssertEqual(self.viewModel.displayedCities.count, 4)
            XCTAssertEqual(self.viewModel.loadingData, false)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testFilterItemsWithMatchingCity() async {
        viewModel.cities = await mockAPIClient.fetchCities()
        viewModel.searchText = "New"

        let expectation = XCTestExpectation(description: "Wait for filterItems to complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.viewModel.displayedCities.count, 1)
            XCTAssertEqual(self.viewModel.displayedCities.first?.name, "New York")
            XCTAssertEqual(self.viewModel.notFound, false)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testFilterItemsWithNoMatchingCity() async {
        viewModel.cities = await mockAPIClient.fetchCities()
        viewModel.searchText = "Miami"

        let expectation = XCTestExpectation(description: "Wait for filterItems to complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.viewModel.displayedCities.count, 0)
            XCTAssertEqual(self.viewModel.notFound, true)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testFilterItemsWithEmptySearchText() async {
        viewModel.cities = await mockAPIClient.fetchCities()
        viewModel.searchText = ""

        let expectation = XCTestExpectation(description: "Wait for filterItems to complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.viewModel.displayedCities.count, 4)
            XCTAssertEqual(self.viewModel.notFound, false)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testShowOnlyFavorites() async {
        viewModel.cities = await mockAPIClient.fetchCities()
        viewModel.displayedCities = viewModel.cities

        viewModel.showOnlyFavorites(true)
        XCTAssertEqual(viewModel.displayedCities.count, 2)
        XCTAssertTrue(viewModel.displayedCities.allSatisfy { $0.isFavorite })

        viewModel.showOnlyFavorites(false)
        XCTAssertEqual(viewModel.displayedCities.count, 4)
    }
}
