//
//  HomeViewController.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import UIKit

class HomeViewController: UIViewController {
    // MARK: - Constants
    static let cellIdentifier: String = "CityCell"
    
    // MARK: - Types
    enum Section: Int, CaseIterable {
        case recent
        case results
        
        var title: String {
            switch self {
            case .recent: return "Recent"
            case .results: return "Results"
            }
        }
    }
    
    // MARK: - UIs
    @IBOutlet private weak var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)
    private lazy var spinner: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    private lazy var spinnerItem = UIBarButtonItem(customView: spinner)
    
    // MARK: - Dependencies
    private var viewModel: IHomeViewModel
    var onCitySelected: ((City) -> Void)?
    
    // MARK: - State
    private var latestState = HomeViewState()
    
    // MARK: - Init
    init(viewModel: IHomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HomeViewController.self), bundle: Bundle.main)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.onViewWillAppear()
        clearSearch()
    }
}

// MARK: - Setup UIs
private extension HomeViewController {
    func setupUI() {
        title = "Home"
        setupTable()
        setupSearch()
    }
    
    func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: HomeViewController.cellIdentifier)
        tableView.keyboardDismissMode = .onDrag
    }
    
    func setupSearch() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search city"
        searchController.searchBar.autocapitalizationType = .words
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
}

// MARK: - Private function
private extension HomeViewController {
    func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.render(state)
            }
        }
    }
    
    func render(_ state: HomeViewState) {
        if state.isLoading {
            navigationItem.rightBarButtonItem = spinnerItem
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
            navigationItem.rightBarButtonItem = nil
        }

        latestState = state
        tableView.reloadData()
    }
    
    func clearSearch() {
        searchController.searchBar.text = nil
        viewModel.onSearchTextChanged("")
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Section(rawValue: section)!
        switch section {
        case .recent:
            return max(latestState.recentCities.count, 1)
            
        case .results:
            if let _ = latestState.errorMessage { return 1 }
            if latestState.isLoading && latestState.searchResults.isEmpty { return 1 }
            if latestState.query.isEmpty { return 0 }
            return latestState.searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeViewController.cellIdentifier, for: indexPath)
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.textColor = .label
        cell.accessoryType = .none
        cell.selectionStyle = .default
        
        guard let section = Section(rawValue: indexPath.section) else { return cell }
        
        switch section {
        case .recent:
            if latestState.recentCities.isEmpty {
                cell.textLabel?.text = "You haven't viewed any city yet."
                cell.textLabel?.textColor = .secondaryLabel
                cell.selectionStyle = .none
                return cell
            }
            
            let city = latestState.recentCities[indexPath.row]
            cell.textLabel?.text = "\(city.name), \(city.country)"
            cell.accessoryType = .disclosureIndicator
            return cell
            
        case .results:
            if let error = latestState.errorMessage, !error.isEmpty {
                cell.textLabel?.text = error
                cell.textLabel?.textColor = .systemRed
                cell.selectionStyle = .none
                return cell
            }
            
            if latestState.isLoading && latestState.searchResults.isEmpty {
                cell.textLabel?.text = "Loading..."
                cell.textLabel?.textColor = .secondaryLabel
                cell.selectionStyle = .none
                return cell
            }
            
            let city = latestState.searchResults[indexPath.row]
            cell.textLabel?.text = "\(city.name), \(city.country)"
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = Section(rawValue: section) else { return 0.01 }
        switch section {
        case .recent:
            return 44
        case .results:
            return latestState.query.isEmpty ? 0.01 : 44
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = Section(rawValue: section) else { return nil }
        if section == .results && latestState.query.isEmpty {
            return nil
        }
        let container = UIView()
        container.backgroundColor = .clear
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.text = section.title
        
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        
        return container
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        var city: City
        switch section {
        case .recent:
            if latestState.recentCities.isEmpty { return }
            city = latestState.recentCities[indexPath.row]
        case .results:
            if latestState.searchResults.isEmpty || latestState.errorMessage != nil { return }
            city = latestState.searchResults[indexPath.row]
        }
        viewModel.cityViewed(city)
        onCitySelected?(city)
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.onSearchTextChanged(searchText)
    }
}

#if DEBUG
extension HomeViewController {
    func tableViewNumberOfSectionsForTesting() -> Int {
        tableView.numberOfSections
    }

    func tableViewNumberOfRowsForTesting(section: Int) -> Int {
        self.tableView(tableView, numberOfRowsInSection: section)
    }

    func tableViewCellForTesting(section: Int, row: Int) -> UITableViewCell? {
        self.tableView(tableView, cellForRowAt: IndexPath(row: row, section: section))
    }

    func tableViewDidSelectRowForTesting(section: Int, row: Int) {
        self.tableView(tableView, didSelectRowAt: IndexPath(row: row, section: section))
    }
    
    func searchTextForTesting_set(_ text: String) {
        navigationItem.searchController?.searchBar.text = text
    }

    func searchTextForTesting_get() -> String? {
        navigationItem.searchController?.searchBar.text
    }

    func triggerViewWillAppearForTesting() {
        viewWillAppear(false)
    }
}
#endif
