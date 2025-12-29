//
//  MockHTTPClient.swift
//  WeatherApp
//
//  Created by Max Nguyen on 28/12/25.
//

import Foundation
@testable import WeatherApp

final class MockURLSessionHTTPClient: HTTPClient {
    private(set) var callCount = 0
    private let stubbedResult: Result<(Data, Int), Error>
    
    init(stubbedResult: Result<(Data, Int), Error> = .success((Data(), 200))) {
        self.stubbedResult = stubbedResult
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        callCount += 1
        switch stubbedResult {
        case .success((let stubbedData, let stubbedStatusCode)):
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: stubbedStatusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (stubbedData, response)
        case .failure(let error):
            throw error
        }
        
    }
}
