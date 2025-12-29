//
//  URLSessionHTTPClientTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import XCTest
@testable import WeatherApp

final class URLSessionHTTPClientTests: XCTestCase {
    private var mockDataHelper: MockDataHelper!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDataHelper = MockDataHelper()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        mockDataHelper = nil
    }
    
    func test_data_returnsDataAndHTTPResponse_onValidResponse() async throws {
        let expectedData = Data("test".utf8)
        let response = HTTPURLResponse(
            url: mockDataHelper.makeUnitTestURL(),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        URLProtocolStub.startIntercepting(URLProtocolStub.Stub(data: expectedData, response: response, error: nil))
        defer { URLProtocolStub.stopIntercepting() }

        let client = makeURLSessionHTTPClient()
        let request = URLRequest(url: response!.url!)

        let (data, httpResponse) = try await client.data(for: request)

        XCTAssertEqual(data, expectedData)
        XCTAssertEqual(httpResponse.statusCode, 200)
    }
    
    func test_data_throwsBadServerResponse_whenResponseIsNotHTTP() async {
        let response = URLResponse(
            url: mockDataHelper.makeUnitTestURL(),
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )

        URLProtocolStub.startIntercepting(URLProtocolStub.Stub(data: Data(), response: response, error: nil))
        defer { URLProtocolStub.stopIntercepting() }

        let client = makeURLSessionHTTPClient()
        let request = URLRequest(url: response.url!)

        do {
            _ = try await client.data(for: request)
            XCTFail("Expected error")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .badServerResponse)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }
    
    func test_data_throwsError_whenSessionThrows() async {
        let expectedError = URLError(.notConnectedToInternet)

        URLProtocolStub.startIntercepting(URLProtocolStub.Stub(data: nil, response: nil, error: expectedError))
        defer { URLProtocolStub.stopIntercepting() }

        let client = makeURLSessionHTTPClient()
        let request = URLRequest(url: mockDataHelper.makeUnitTestURL())

        do {
            _ = try await client.data(for: request)
            XCTFail("Expected error")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .notConnectedToInternet)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }
}

// MARK: - Private function
private extension URLSessionHTTPClientTests {
    func makeURLSessionHTTPClient() -> URLSessionHTTPClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: config)
        return URLSessionHTTPClient(session: session)
    }
}

private final class URLProtocolStub: URLProtocol {
    static var stub: Stub?

    struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }

    static func startIntercepting(_ stub: Stub) {
        URLProtocolStub.stub = stub
    }

    static func stopIntercepting() {
        URLProtocolStub.stub = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let stub = URLProtocolStub.stub else { return }

        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
