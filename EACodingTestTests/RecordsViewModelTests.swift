//
//  RecordsViewModelTests.swift
//  RecordsViewModelTests
//
//  Created by Shweta Verma on 11/4/2023.
//

import XCTest
@testable import EACodingTest

final class RecordsViewModelTests: XCTestCase {
    
    private var viewModel: RecordsViewModel!
    private var festivals: [Festival] = []
    private enum TestError: Error {
        case anError
    }
    private var mockNetworkManager: MockNetworkManager!
    private var mockRecordsViewModelDisplayDelegate: MockRecordsViewModelDisplayDelegate!

    
    override func tearDown() {
        viewModel = nil
        mockNetworkManager = nil
        mockRecordsViewModelDisplayDelegate = nil
    }

    override func setUp() {
        mockNetworkManager = MockNetworkManager()
        viewModel = RecordsViewModel(networkManager: mockNetworkManager)
        mockRecordsViewModelDisplayDelegate = MockRecordsViewModelDisplayDelegate()
        viewModel.displayDelegate = mockRecordsViewModelDisplayDelegate
        festivals = [Festival.mock(name: "Fest B", bands: [Band.mock(name: "Nirvana", recordLabel: "record X"),
                                                               Band.mock(name: "ACDC", recordLabel: "record C")]),
                        Festival.mock(name: "Fest A", bands: [Band.mock(name: "ColdPlay", recordLabel: "record C"),
                                                               Band.mock(name: "ACDC", recordLabel: "record C")]),
                        Festival.mock(name: "Fest J", bands: [Band.mock(name: "UM", recordLabel: "record B"),
                                                            Band.mock(name: "Pink Floyd", recordLabel: "record SJ")])]
        viewModel.configure(festivals: festivals)
    }
    
    func testNumberOfRecordLabels() {
        XCTAssertEqual(viewModel.numberOfRecordLabels, 4)
    }
    
    func testNumberOfBandsInRecordLabels() {
        XCTAssertEqual(viewModel.numberOfBands(in: 0), 1) // For record Label record B
        XCTAssertEqual(viewModel.numberOfBands(in: 1), 2) // For record Label record C
        XCTAssertEqual(viewModel.numberOfBands(in: 2), 1) // For record Label record SJ
        XCTAssertEqual(viewModel.numberOfBands(in: 3), 1) // For record Label record X
    }
    
    func testSortedRecordLabels() {
        XCTAssertEqual(viewModel.recordLabels[0], "record B")
        XCTAssertEqual(viewModel.recordLabels[1], "record C")
        XCTAssertEqual(viewModel.recordLabels[2], "record SJ")
        XCTAssertEqual(viewModel.recordLabels[3], "record X")
    }
    
    func testSortedBandsInRecordLabels() {
        // For record Label record B
        XCTAssertEqual(viewModel.band(at: IndexPath(row: 0, section: 0)).name, "UM")
        // For record Label record C
        XCTAssertEqual(viewModel.band(at: IndexPath(row: 0, section: 1)).name, "ACDC")
        XCTAssertEqual(viewModel.band(at: IndexPath(row: 1, section: 1)).name, "ColdPlay")
        // For record Label record SJ
        XCTAssertEqual(viewModel.band(at: IndexPath(row: 0, section: 2)).name, "Pink Floyd")
        // For record Label record X
        XCTAssertEqual(viewModel.band(at: IndexPath(row: 0, section: 3)).name, "Nirvana")
    }
    
    func testSortedFestivalsInBand() {
        var festivals = viewModel.festivalNames(band: Band.mock(name: "ACDC", recordLabel: "record C"))
        XCTAssertEqual(festivals.count, 2)
        XCTAssertEqual(festivals[0], "Fest A")
        XCTAssertEqual(festivals[1], "Fest B")
        
        festivals = viewModel.festivalNames(band: Band.mock(name: "Nirvana", recordLabel: "record X"))
        XCTAssertEqual(festivals.count, 1)
        XCTAssertEqual(festivals[0], "Fest B")

        festivals = viewModel.festivalNames(band: Band.mock(name: "ColdPlay", recordLabel: "record C"))
        XCTAssertEqual(festivals.count, 1)
        XCTAssertEqual(festivals[0], "Fest A")

        festivals = viewModel.festivalNames(band: Band.mock(name: "UM", recordLabel: "record B"))
        XCTAssertEqual(festivals.count, 1)
        XCTAssertEqual(festivals[0], "Fest J")

        festivals = viewModel.festivalNames(band:  Band.mock(name: "Pink Floyd", recordLabel: "record SJ"))
        XCTAssertEqual(festivals.count, 1)
        XCTAssertEqual(festivals[0], "Fest J")
    }
    
    func testRequestSuccess() {
        mockNetworkManager.mockedResult = festivals
        mockNetworkManager.mockedError = nil
        XCTAssertEqual(mockRecordsViewModelDisplayDelegate.successCount, 0)
        XCTAssertEqual(mockRecordsViewModelDisplayDelegate.failureCount, 0)
        viewModel.fetchFestivals()
        XCTAssertEqual(mockRecordsViewModelDisplayDelegate.successCount, 1)
        XCTAssertEqual(mockRecordsViewModelDisplayDelegate.failureCount, 0)
    }
    
    func testRequestFailure() {
        mockNetworkManager.mockedError = TestError.anError
        mockNetworkManager.mockedResult = nil
        XCTAssertEqual(mockRecordsViewModelDisplayDelegate.successCount, 0)
        XCTAssertEqual(mockRecordsViewModelDisplayDelegate.failureCount, 0)
        viewModel.fetchFestivals()
        XCTAssertEqual(mockRecordsViewModelDisplayDelegate.successCount, 0)
        XCTAssertEqual(mockRecordsViewModelDisplayDelegate.failureCount, 1)
    }

}

final class MockRecordsViewModelDisplayDelegate: RecordsViewModelDisplayDelegate {
    var successCount = 0
    var failureCount = 0

    func recordsDidLoadSuccess(_ viewModel: RecordsViewModel) {
        successCount+=1
    }
    
    func recordsDidLoadFailure(_ viewModel: RecordsViewModel, error: APIError) {
        failureCount+=1
    }
}
