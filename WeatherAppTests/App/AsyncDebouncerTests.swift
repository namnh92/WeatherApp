//
//  AsyncDebouncerTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import XCTest
@testable import WeatherApp

final class AsyncDebouncerTests: XCTestCase {

    func test_schedule_executesAction_afterDelay() async {
        let debouncer = AsyncDebouncer(delay: 0.05)
        let exp = expectation(description: "action executed")

        debouncer.schedule {
            exp.fulfill()
        }

        await fulfillment(of: [exp], timeout: 1.0)
    }

    func test_schedule_multipleTimes_onlyLastActionExecutes() async {
        let debouncer = AsyncDebouncer(delay: 0.05)

        let firstShouldNotRun = expectation(description: "first action should not run")
        firstShouldNotRun.isInverted = true

        let lastShouldRun = expectation(description: "last action should run")

        debouncer.schedule {
            firstShouldNotRun.fulfill()
        }

        debouncer.schedule {
            lastShouldRun.fulfill()
        }

        await fulfillment(of: [firstShouldNotRun, lastShouldRun], timeout: 1.0)
    }

    func test_cancel_preventsScheduledAction_fromExecuting() async {
        let debouncer = AsyncDebouncer(delay: 0.05)

        let shouldNotRun = expectation(description: "action should not run")
        shouldNotRun.isInverted = true

        debouncer.schedule {
            shouldNotRun.fulfill()
        }
        debouncer.cancel()

        await fulfillment(of: [shouldNotRun], timeout: 0.2)
    }

    func test_cancel_thenSchedule_executesNewAction() async {
        let debouncer = AsyncDebouncer(delay: 0.05)

        let firstShouldNotRun = expectation(description: "first action should not run")
        firstShouldNotRun.isInverted = true

        let secondShouldRun = expectation(description: "second action should run")

        debouncer.schedule {
            firstShouldNotRun.fulfill()
        }
        debouncer.cancel()

        debouncer.schedule {
            secondShouldRun.fulfill()
        }

        await fulfillment(of: [firstShouldNotRun, secondShouldRun], timeout: 1.0)
    }
}
