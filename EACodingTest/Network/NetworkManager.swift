//
//  NetworkManager.swift
//  EACodingTest
//
//  Created by Shweta Verma on 12/4/2023.
//

import Foundation

protocol Networking {
    func loadApiResponseFrom<T: Decodable>(url: URL, completion: @escaping (Result<T, APIError>) -> Void)
}

enum APIError: Error, Equatable {
    case tooManyRequest
    case dataNotDecodable
    case httpNoResponse
    case httpNoData(status: Int)
    case unknown
            
    var errorMessage: String {
        switch self {
        case .tooManyRequest:
            return "Too many requests. Please try again later."
        case .dataNotDecodable:
            return "Not a valid data to display."
        case .httpNoResponse:
            return "The requested resource could not be found."
        case .httpNoData(status: _):
            return "An error occurred on the server. Please try again later."
        case .unknown:
            return "An unknown error occurred."
        }
    }

}

struct NetworkManager: Networking {
    // MARK: - Private properties
    
    private let session: URLSession
    
    // MARK: - Lifecycle

    init(session: URLSession = .shared) {
        self.session = session
    }

    func loadApiResponseFrom<T: Decodable>(url: URL, completion: @escaping (Result<T, APIError>) -> Void) {
        let task = session.dataTask(with: url, completionHandler: {(data, urlResponse, error) in
            if let error = error {
                completion(.failure(error as! APIError))
            }
            
            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                completion(.failure(APIError.httpNoResponse))
                return
            }
            
            guard urlResponse.statusCode != 429 else {
                completion(.failure(APIError.tooManyRequest))
                return
            }
            print(urlResponse.statusCode)
            
            guard let data = data,
                !data.isEmpty else {
                completion(.failure(APIError.httpNoData(status: urlResponse.statusCode)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(T.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(APIError.dataNotDecodable))
            }
        })
        task.resume()
    }
}

