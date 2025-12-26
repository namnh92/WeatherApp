//
//  DependencyResolver.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import Foundation
import UIKit

class DependencyResolver {
    //MARK: - Singleton
    static let shared = DependencyResolver()
    
    //MARK: - Core
    private lazy var httpClient: HTTPClient = URLSessionHTTPClient()
    private lazy var apiConfig: APIConfig = APIConfig(apiKey: AppConfiguration.apiKey, apiBaseURL: URL(string: AppConfiguration.apiBaseURL))
    private lazy var queryAdapter = QueryAdapter(apiConfig: apiConfig)
    private lazy var responseAdapter = ResponseAdapter()
    
    //MARK: - Repositories
    private lazy var cityRepository: ICityRepository = CityRepositoryImpl(client: httpClient, queryAdapter: queryAdapter, responseAdapter: responseAdapter)
    
    //MARK: - UseCases
    private lazy var getCityUseCase: IGetCityUseCase = GetCityUseCase(repository: cityRepository)
    
    //MARK: - ViewModels
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(getCityUseCase: getCityUseCase, debouncer: AsyncDebouncer(delay: AppConfiguration.debounceTime))
    }
}

// MARK: - Make ViewControllers
extension DependencyResolver {
    func makeHomeViewController(navigation: UINavigationController) -> HomeViewController {
        let vm = makeHomeViewModel()
        let vc = HomeViewController(viewModel: vm)

        vc.onCitySelected = { [weak navigation] city in
            guard let navigation else { return }
            // TODO: City Screen
        }

        return vc
    }
}
