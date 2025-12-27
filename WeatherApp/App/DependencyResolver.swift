//
//  DependencyResolver.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import Foundation
import UIKit
import SwiftUI

class DependencyResolver {
    //MARK: - Singleton
    static let shared = DependencyResolver()
    
    //MARK: - Core
    private lazy var httpClient: HTTPClient = URLSessionHTTPClient()
    private lazy var apiConfig: APIConfig = APIConfig(apiKey: AppConfiguration.API.apiKey, apiBaseURL: URL(string: AppConfiguration.API.apiBaseURL))
    private lazy var queryAdapter = QueryAdapter(apiConfig: apiConfig)
    private lazy var responseAdapter = ResponseAdapter()
    
    //MARK: - Repositories
    private lazy var cityRepository: ICityRepository = CityRepositoryImpl(client: httpClient, queryAdapter: queryAdapter, responseAdapter: responseAdapter)
    private lazy var weatherRepository: IWeatherRepository = WeatherRepositoryImpl(client: httpClient, queryAdapter: queryAdapter, responseAdapter: responseAdapter)
    
    //MARK: - Store
    private lazy var recentStore: IRecentCityStore = UserDefaultsRecentCityStore()
    
    //MARK: - UseCases
    private lazy var getCityUseCase: IGetCityUseCase = GetCityUseCase(repository: cityRepository)
    private lazy var getWeatherUseCase: IGetWeatherUseCase = GetWeatherUseCase(repository: weatherRepository)
    private lazy var getRecentCityUseCase: IGetRecentCityUseCase = GetRecentCityUseCase(store: recentStore)
    
    //MARK: - ViewModels
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(getCityUseCase: getCityUseCase, getRecentCityUseCase: getRecentCityUseCase, debouncer: AsyncDebouncer(delay: AppConfiguration.debounceTime))
    }
}

// MARK: - Make ViewControllers
extension DependencyResolver {
    func makeHomeViewController(navigation: UINavigationController) -> HomeViewController {
        let vm = makeHomeViewModel()
        let vc = HomeViewController(viewModel: vm)

        vc.onCitySelected = { [weak navigation, weak self] city in
            guard let navigation, let self else { return }
            let cityView = self.makeCityView(city: city)
            let host = UIHostingController(rootView: cityView)
            navigation.pushViewController(host, animated: true)
        }

        return vc
    }
    
    func makeCityView(city: City) -> CityView {
        let vm = CityViewModel(city: city, useCase: getWeatherUseCase)
        return CityView(city: city, viewModel: vm)
    }
}
