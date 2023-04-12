//
//  MockFestivals.swift
//  EACodingTestTests
//
//  Created by Shweta Verma on 12/4/2023.
//

import Foundation
@testable import EACodingTest

extension Festival {
    static func mock(name: String,
                     bands: [Band]) -> Festival {
        return Festival(name: name,
                        bands: bands)
    }
}

extension Band {
    static func mock(name: String,
                     recordLabel: String) -> Band {
        return Band(name: name,
                        recordLabel: recordLabel)
    }
}
