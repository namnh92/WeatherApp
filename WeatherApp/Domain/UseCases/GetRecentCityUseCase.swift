//
//  GetRecentCityUseCase.swift
//  WeatherApp
//
//  Created by Max Nguyen on 27/12/25.
//

protocol IGetRecentCityUseCase {
    func execute(_ numberPerPage: Int) -> [City]
    func save(_ city: City)
}

struct GetRecentCityUseCase: IGetRecentCityUseCase {
    private let store: IRecentCityStore
    
    init(store: IRecentCityStore) {
        self.store = store
    }
    
    func execute(_ numberPerPage: Int) -> [City] {
        return store.load(numberPerPage)
    }
    
    func save(_ city: City) {
        store.save(city)
    }
}
