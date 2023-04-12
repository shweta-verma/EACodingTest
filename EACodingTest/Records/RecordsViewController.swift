//
//  RecordsViewController.swift
//  EACodingTest
//
//  Created by Shweta Verma on 11/4/2023.
//

import UIKit

final class RecordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RecordsViewModelDisplayDelegate {
    // MARK: - Enums

    private enum Constants {
        static let festivalCell = "FestivalCell"
    }
    // MARK: - Outlets
    
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.festivalCell)
        }
    }
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    // MARK: Private properties

    private var viewModel: RecordsViewModel?
    private var refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        viewModel = RecordsViewModel()
        viewModel?.displayDelegate = self
        configureRefreshControl()
        showLoader()
        viewModel?.fetchFestivals()
    }
    
    // MARK: - Private function
    
    private func configureRefreshControl(){
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(pulledRefreshControl(_:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc private func pulledRefreshControl(_ sender:AnyObject) {
        viewModel?.fetchFestivals()
        sender.endRefreshing()
    }
    
    private func showLoader() {
        loader.isHidden = false
    }

    private func hideLoader() {
        loader.isHidden = true
    }
        
    // MARK: - UITableViewDataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfRecordLabels ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfBands(in: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.festivalCell, for: indexPath)
        if let band = viewModel?.band(at: indexPath){
            guard let festivalNames = viewModel?.festivalNames(band: band) else {
                cell.textLabel?.text = band.name
                return cell
            }
            if !festivalNames.isEmpty {
                let allFestivals = festivalNames.joined(separator: "\n\t")
                cell.textLabel?.text = band.name+"\n\t"+allFestivals
                cell.textLabel?.numberOfLines = allFestivals.count
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let recordLabel = viewModel?.recordLabels[section]
        let headerView = UIView()
        headerView.backgroundColor = UIColor.gray // set the background color
        
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.size.width - 15, height: 30))
        headerLabel.textColor = UIColor.white // set the text color
        headerLabel.font = UIFont.boldSystemFont(ofSize: 20) // set the font
        headerLabel.text = recordLabel
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    // MARK: - RecordsViewModelDelegate
    
    func recordsDidLoadSuccess(_ viewModel: RecordsViewModel) {
        DispatchQueue.main.async { [weak self] in
            self?.hideLoader()
            self?.tableView.reloadData()
        }
    }
    
    func recordsDidLoadFailure(_ viewModel: RecordsViewModel, error: APIError) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Error", message: error.errorMessage, preferredStyle: .alert)

            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: self?.retryAction)
            alertController.addAction(retryAction)
            self?.present(alertController, animated: true, completion: nil)
            self?.hideLoader()
        }
    }
    
    func retryAction(_ action: UIAlertAction) {
        viewModel?.fetchFestivals()
    }

}


