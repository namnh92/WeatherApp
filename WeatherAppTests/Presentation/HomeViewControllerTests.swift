//
//  HomeViewControllerTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//
import XCTest
@testable import WeatherApp

final class HomeViewControllerTests: XCTestCase {
    private var mockDataHelper: MockDataHelper!
    private var cities: [City] = []
    private var viewModel: MockHomeViewModel!
    private var homeViewController: HomeViewController!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDataHelper = MockDataHelper()
        cities = mockDataHelper.loadCities()
        viewModel = MockHomeViewModel()
        homeViewController = HomeViewController(viewModel: viewModel)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        mockDataHelper = nil
        cities = []
        viewModel = nil
        homeViewController = nil
    }

    func test_numberOfSections_isTwo() {
        homeViewController.loadViewIfNeeded()

        XCTAssertEqual(homeViewController.tableViewNumberOfSectionsForTesting(), 2)
    }

    func test_recentSection_whenEmpty_showsEmptyStateRow() throws {
        homeViewController.loadViewIfNeeded()

        viewModel.emit(HomeViewState(query: "", searchResults: [], recentCities: [], isLoading: false, errorMessage: nil))
        drainMainQueue()

        XCTAssertEqual(homeViewController.tableViewNumberOfRowsForTesting(section: HomeViewController.Section.recent.rawValue), 1)

        let cell = try XCTUnwrap(homeViewController.tableViewCellForTesting(section: HomeViewController.Section.recent.rawValue, row: 0))
        XCTAssertEqual(cell.textLabel?.text, "You haven't viewed any city yet.")
    }
    
    func test_recentSection_whenHasRecents_showsRecentCityRows() throws {
        homeViewController.loadViewIfNeeded()
        let city = cities.first!
        
        viewModel.emit(HomeViewState(query: "", searchResults: [], recentCities: [city], isLoading: false, errorMessage: nil))
        drainMainQueue()
        
        XCTAssertEqual(homeViewController.tableViewNumberOfRowsForTesting(section: HomeViewController.Section.recent.rawValue), 1)

        let cell = try XCTUnwrap(homeViewController.tableViewCellForTesting(section: HomeViewController.Section.recent.rawValue, row: 0))
        XCTAssertEqual(cell.textLabel?.text, "\(city.name), \(city.country)" )
    }

    func test_resultsSection_whenQueryEmpty_hasZeroRows() {
        homeViewController.loadViewIfNeeded()

        viewModel.emit(HomeViewState(query: "", searchResults: [], recentCities: [], isLoading: false, errorMessage: nil))
        drainMainQueue()

        XCTAssertEqual(homeViewController.tableViewNumberOfRowsForTesting(section: HomeViewController.Section.results.rawValue), 0)
    }

    func test_resultsSection_whenLoadingAndNoResults_showsLoadingRow() throws {
        homeViewController.loadViewIfNeeded()

        viewModel.emit(HomeViewState(query: "H", searchResults: [], recentCities: [], isLoading: true, errorMessage: nil))
        drainMainQueue()

        XCTAssertEqual(homeViewController.tableViewNumberOfRowsForTesting(section: HomeViewController.Section.results.rawValue), 1)

        let cell = try XCTUnwrap(homeViewController.tableViewCellForTesting(section: HomeViewController.Section.results.rawValue, row: 0))
        XCTAssertEqual(cell.textLabel?.text, "Loading...")
    }
    
    func test_resultsSection_whenHasResults_showsResultCityRows() throws {
        homeViewController.loadViewIfNeeded()
        let city = cities.first!
        
        viewModel.emit(HomeViewState(query: "H", searchResults: [city], recentCities: [], isLoading: false, errorMessage: nil))
        drainMainQueue()
        
        XCTAssertEqual(homeViewController.tableViewNumberOfRowsForTesting(section: HomeViewController.Section.results.rawValue), 1)

        let cell = try XCTUnwrap(homeViewController.tableViewCellForTesting(section: HomeViewController.Section.results.rawValue, row: 0))
        XCTAssertEqual(cell.textLabel?.text, "\(city.name), \(city.country)" )
    }

    func test_resultsSection_whenError_showsErrorRow() throws {
        homeViewController.loadViewIfNeeded()

        viewModel.emit(HomeViewState(query: "H", searchResults: [], recentCities: [], isLoading: false, errorMessage: "Search failed"))
        drainMainQueue()

        XCTAssertEqual(homeViewController.tableViewNumberOfRowsForTesting(section: HomeViewController.Section.results.rawValue), 1)

        let cell = try XCTUnwrap(homeViewController.tableViewCellForTesting(section: HomeViewController.Section.results.rawValue, row: 0))
        XCTAssertEqual(cell.textLabel?.text, "Search failed")
    }

    func test_didSelectRow_inRecents_callsCityViewed_andOnCitySelected() {
        homeViewController.loadViewIfNeeded()

        viewModel.emit(HomeViewState(query: "H", searchResults: [], recentCities: cities, isLoading: false, errorMessage: nil))
        drainMainQueue()

        var selected: City?
        homeViewController.onCitySelected = { selected = $0 }

        homeViewController.tableViewDidSelectRowForTesting(section: HomeViewController.Section.recent.rawValue, row: 0)

        XCTAssertEqual(viewModel.cityViewedCalls, [cities.first])
        XCTAssertEqual(selected, cities.first)
    }
    
    func test_didSelectRow_inResults_callsCityViewed_andOnCitySelected() {
        homeViewController.loadViewIfNeeded()

        viewModel.emit(HomeViewState(query: "H", searchResults: cities, recentCities: [], isLoading: false, errorMessage: nil))
        drainMainQueue()

        var selected: City?
        homeViewController.onCitySelected = { selected = $0 }

        homeViewController.tableViewDidSelectRowForTesting(section: HomeViewController.Section.results.rawValue, row: 0)

        XCTAssertEqual(viewModel.cityViewedCalls, [cities.first])
        XCTAssertEqual(selected, cities.first)
    }

    func test_viewWillAppear_clearsSearch_andCallsOnSearchTextChangedWithEmpty() {
        homeViewController.loadViewIfNeeded()

        homeViewController.searchTextForTesting_set("H")
        homeViewController.triggerViewWillAppearForTesting()

        XCTAssertEqual(viewModel.onViewWillAppearCallCount, 1)
        XCTAssertEqual(viewModel.searchTextChangedCalls.last, "")
        XCTAssertEqual(homeViewController.searchTextForTesting_get(), "")
    }
    
    func test_searchBarSearchButtonClicked_callsResignFirstResponder() {
        homeViewController.loadViewIfNeeded()

        let searchBar = UISearchBarSpy()

        homeViewController.searchBarSearchButtonClicked(searchBar)

        XCTAssertTrue(searchBar.didResignFirstResponder)
    }
    
    func test_searchBarTextDidChange_callsViewModel() {
        homeViewController.loadViewIfNeeded()

        let searchBar = UISearchBar()

        homeViewController.searchBar(searchBar, textDidChange: "H")

        XCTAssertEqual(viewModel.searchTextChangedCalls, ["H"])
    }
}

private final class MockHomeViewModel: IHomeViewModel {
    var onStateChange: ((HomeViewState) -> Void)?

    private(set) var onViewWillAppearCallCount = 0
    private(set) var searchTextChangedCalls: [String] = []
    private(set) var cityViewedCalls: [City] = []

    func onViewWillAppear() {
        onViewWillAppearCallCount += 1
    }

    func onSearchTextChanged(_ text: String) {
        searchTextChangedCalls.append(text)
    }

    func cityViewed(_ city: City) {
        cityViewedCalls.append(city)
    }

    func emit(_ state: HomeViewState) {
        onStateChange?(state)
    }
}

private final class UISearchBarSpy: UISearchBar {
    private(set) var didResignFirstResponder = false

    override func resignFirstResponder() -> Bool {
        didResignFirstResponder = true
        return true
    }
}

private func drainMainQueue(file: StaticString = #filePath, line: UInt = #line) {
    let exp = XCTestExpectation(description: "drain main")
    DispatchQueue.main.async { exp.fulfill() }
    let result = XCTWaiter.wait(for: [exp], timeout: 1.0)
    if result != .completed {
        XCTFail("Main queue did not drain", file: file, line: line)
    }
}
