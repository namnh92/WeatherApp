//
//  ImageCacheTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import XCTest
import UIKit
@testable import WeatherApp

final class ImageCacheTests: XCTestCase {
    private var mockDataHelper: MockDataHelper!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDataHelper = MockDataHelper()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        mockDataHelper = nil
    }

    func test_image_forURL_whenNotInserted_returnsNil() {
        let imageCache = ImageCache()
        let url = mockDataHelper.makeUnitTestURL()
        
        let result = imageCache.image(for: url)

        XCTAssertNil(result)
    }

    func test_insert_thenImage_forSameURL_returnsSameImageInstance() {
        let imageCache = ImageCache()
        let url = mockDataHelper.makeUnitTestURL()
        
        let image = UIImage(systemName: "star")!
        
        imageCache.insert(image, for: url)
        let result = imageCache.image(for: url)

        XCTAssertNotNil(result)
        XCTAssertTrue(result === image)
    }

    func test_insert_twoDifferentURLs_doesNotOverrideEachOther() {
        let imageCache = ImageCache()
        let urlA = URL(string: "https://urlA.com")!
        let urlB = URL(string: "https://urlB.com")!
        
        let imageA = UIImage(systemName: "star")!
        let imageB = UIImage(systemName: "heart")!

        imageCache.insert(imageA, for: urlA)
        imageCache.insert(imageB, for: urlB)

        XCTAssertTrue(imageCache.image(for: urlA) === imageA)
        XCTAssertTrue(imageCache.image(for: urlB) === imageB)
    }
}
