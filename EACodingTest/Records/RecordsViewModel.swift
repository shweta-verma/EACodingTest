//
//  RecordsViewModel.swift
//  EACodingTest
//
//  Created by Shweta Verma on 12/4/2023.
//

import UIKit

protocol RecordsViewModelDisplayDelegate: AnyObject {
    func recordsDidLoadSuccess(_ viewModel: RecordsViewModel)
    func recordsDidLoadFailure(_ viewModel: RecordsViewModel, error: APIError)
}

final class RecordsViewModel {
    // MARK: - Private properties

    private var festivals: [Festival] = []
    
    // MARK: - Public properties

    var networkManager: Networking
    weak var displayDelegate: RecordsViewModelDisplayDelegate?
    var recordLabels: [String] = []
    var numberOfRecordLabels: Int { recordLabels.count }
    let requestUrl = "https://eacp.energyaustralia.com.au/codingtest/api/v1/festivals"

    // MARK: - Initializer
    init(networkManager: Networking = NetworkManager()) {
        self.networkManager = networkManager
    }

    // MARK: - Public functions
    
    func configure(festivals: [Festival]) {
        self.festivals = festivals
        self.recordLabels = Array(Set(festivals
                           .flatMap { $0.bands }
                           .compactMap { $0.recordLabel }))
                           .sorted { $0 < $1 }
    }
            
    func numberOfBands(in section: Int) -> Int {
        let recordLabel = recordLabels[section]
        let bands = Array(Set(festivals
            .flatMap { $0.bands }
            .filter { $0.recordLabel == recordLabel }))
        return bands.count
    }
        
    func band(at indexPath: IndexPath) -> Band {
        let recordLabel = recordLabels[indexPath.section]
        let bands = Array(Set(festivals
                   .flatMap { $0.bands }
                   .filter { $0.recordLabel == recordLabel }))
                   .sorted { $0.name < $1.name }
        return bands[indexPath.row]
    }
        

    func festivalNames(band: Band) -> [String] {
        var festivalNames = [String]()
        for festival in festivals {
            for bandInFestival in festival.bands {
                if bandInFestival.name == band.name && bandInFestival.recordLabel == band.recordLabel {
                    festivalNames.append(festival.name ?? "")
                }
            }
        }
        return festivalNames.sorted()
    }
    
    func fetchFestivals() {
        guard let requestUrl = URL(string: requestUrl) else { return }
        networkManager.loadApiResponseFrom(url: requestUrl) { [weak self] (result: Result<[Festival], APIError>) in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                self.displayDelegate?.recordsDidLoadFailure(self, error: error)
            case let .success(data):
                self.configure(festivals: data)
                self.displayDelegate?.recordsDidLoadSuccess(self)
            }
        }
    }
}
