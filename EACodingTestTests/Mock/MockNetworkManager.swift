//
//  MockNetworkManager.swift
//  EACodingTestTests
//
//  Created by Shweta Verma on 12/4/2023.
//

import Foundation
import UIKit
@testable import EACodingTest

final class MockNetworkManager: Networking {
    var mockedResult: Decodable?
    var mockedError: Error?

    func loadApiResponseFrom<T: Decodable>(url: URL, completion: @escaping (Result<T, APIError>) -> Void) {
        if let error = mockedError as? APIError {
            completion(.failure(error))
            return
        }
        
        guard let result = mockedResult as? T else {
            completion(.failure(APIError.httpNoData(status: 401)))
            return
        }
        completion(.success(result))
    }
}
