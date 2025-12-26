//
//  GetCityUseCase.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

protocol IGetCityUseCase {
    func execute(_ query: String) async throws -> [City]
}

struct GetCityUseCase: IGetCityUseCase {
    private let repository: ICityRepository
    
    init(repository: ICityRepository) {
        self.repository = repository
    }
    
    func execute(_ query: String) async throws -> [City] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return try await repository.getCities(trimmed)
    }
}
