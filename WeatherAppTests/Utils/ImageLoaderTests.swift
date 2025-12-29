//
//  ImageLoaderTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import XCTest
import Combine
@testable import WeatherApp

final class ImageLoaderTests: XCTestCase {
    private var mockDataHelper: MockDataHelper!
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDataHelper = MockDataHelper()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        mockDataHelper = nil
        cancellables.removeAll()
        
    }

    func test_load_whenCached_setsImageImmediately_andDoesNotCallClient() {
        let url = mockDataHelper.makeUnitTestURL()
        let cached = UIImage(systemName: "star")!

        let cache = ImageCacheSpy()
        cache.storage[url] = cached

        let client = MockURLSessionHTTPClient(stubbedResult: .success(( make1x1PNGData(), stubbedStatusCode: 200)))
        let imageLoader = ImageLoader(url: url, cache: cache, client: client, errorImage: UIImage(systemName: "exclamationmark.triangle"))

        imageLoader.load()

        XCTAssertTrue(imageLoader.image === cached)
        XCTAssertEqual(client.callCount, 0)
        XCTAssertEqual(cache.insertCallCount, 0)
    }

    func test_load_whenClientReturnsValidImage_setsImage_andCachesIt() async {
        let url = mockDataHelper.makeUnitTestURL()
        let cache = ImageCacheSpy()
        let client = MockURLSessionHTTPClient(stubbedResult: .success(( make1x1PNGData(), stubbedStatusCode: 200)))
        let errorImage = UIImage(systemName: "exclamationmark.triangle")!
        let imageLoader = ImageLoader(url: url, cache: cache, client: client, errorImage: errorImage)

        let exp = expectation(description: "image published")
        imageLoader.$image.dropFirst().sink { img in
            if img != nil { exp.fulfill() }
        }.store(in: &cancellables)

        imageLoader.load()

        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertNotNil(imageLoader.image)
        XCTAssertEqual(client.callCount, 1)
        XCTAssertEqual(cache.insertCallCount, 1)
    }

    func test_load_whenClientReturnsNonImage_setsErrorImage_andDoesNotCache() async {
        let url = mockDataHelper.makeUnitTestURL()
        let cache = ImageCacheSpy()
        let client = MockURLSessionHTTPClient(stubbedResult: .success(( Data(), stubbedStatusCode: 500)))
        let errorImage = UIImage(systemName: "exclamationmark.triangle")!
        let imageLoader = ImageLoader(url: url, cache: cache, client: client, errorImage: errorImage)

        let exp = expectation(description: "error image published")
        imageLoader.$image.dropFirst().sink { img in
            if img === errorImage { exp.fulfill() }
        }.store(in: &cancellables)

        imageLoader.load()

        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertTrue(imageLoader.image === errorImage)
        XCTAssertEqual(cache.insertCallCount, 0)
    }

    
    func test_load_whenCancelled_beforeClientThrows_setsErrorImage() async {
        struct DummyError: Error, Equatable {}
        let url = mockDataHelper.makeUnitTestURL()
        let cache = ImageCacheSpy()
        let client = MockURLSessionHTTPClient(stubbedResult: .failure(DummyError()))
        let errorImage = UIImage(systemName: "exclamationmark.triangle")!
        let imageLoader = ImageLoader(url: url, cache: cache, client: client, errorImage: errorImage)
        
        let exp = expectation(description: "error image published")
        imageLoader.$image.dropFirst().sink { img in
            if img === errorImage { exp.fulfill() }
        }.store(in: &cancellables)

        imageLoader.load()
        
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertTrue(imageLoader.image === errorImage)
        XCTAssertEqual(cache.insertCallCount, 0)
    }
    
    func test_cancel_thenLoad_allowsNewLoadToUpdateImage() async {
        let url = mockDataHelper.makeUnitTestURL()
        let cache = ImageCacheSpy()
        let errorImage = UIImage(systemName: "exclamationmark.triangle")!
        
        let firstClient = MockURLSessionHTTPClient(stubbedResult: .success(( make1x1PNGData(), stubbedStatusCode: 200)))
        let imageLoader1 = ImageLoader(url: url, cache: cache, client: firstClient, errorImage: errorImage)
        
        imageLoader1.load()
        imageLoader1.cancel()
        
        let secondClient = MockURLSessionHTTPClient(stubbedResult: .success(( make1x1PNGData(), stubbedStatusCode: 200)))
        let imageLoader2 = ImageLoader(url: url, cache: cache, client: secondClient, errorImage: errorImage)
        
        let exp = expectation(description: "image published")
        imageLoader2.$image.dropFirst().sink { img in
            if img != nil { exp.fulfill() }
        }.store(in: &cancellables)
        
        imageLoader2.load()
        
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertNotNil(imageLoader2.image)
        XCTAssertEqual(cache.insertCallCount, 1)
    }
}

// MARK: - Private function
private extension ImageLoaderTests{
    func make1x1PNGData() -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let img = renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        return img.pngData()!
    }
}

private final class ImageCacheSpy: ImageCaching {
    var storage: [URL: UIImage] = [:]
    private(set) var insertCallCount = 0

    func image(for url: URL) -> UIImage? { storage[url] }

    func insert(_ image: UIImage, for url: URL) {
        insertCallCount += 1
        storage[url] = image
    }
}
