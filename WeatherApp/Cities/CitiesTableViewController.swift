//
//  CitiesTableViewController.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 22.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

class SubtitleTableViewCell: UITableViewCell {

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


class CitiesTableViewController: UITableViewController {

  private var presenter: CitiesPresenterProtocol
  
  private let reuseIdentifier = "DefaultCell"
  
  private var searchBar: UISearchBar?
  private var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
  private let downloadAlertView: UIView = DownloadAlertView()

  // MARK: - Init
  init(presenter: CitiesPresenter) {
   self.presenter = presenter
   super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .systemGray3
    self.tableView.register(SubtitleTableViewCell.self,
                            forCellReuseIdentifier: self.reuseIdentifier)
    let refreshButton = UIBarButtonItem(
      title: "Обновить список городов",
      style: .plain,
      target: self,
      action: #selector(self.refreshCitiesList))
    self.navigationItem.rightBarButtonItem = refreshButton
    
    self.searchBar = UISearchBar()
    self.searchBar?.placeholder = "Введите название города"
    self.searchBar?.delegate = self
    self.searchBar?.barTintColor = .systemGray3
    self.searchBar?.tintColor = .systemIndigo
    self.searchBar?.searchTextField.backgroundColor = .white
    self.tableView.tableHeaderView = self.searchBar
    self.searchBar?.sizeToFit()
    self.view.addSubview(self.downloadAlertView)
    self.downloadAlertView.translatesAutoresizingMaskIntoConstraints = false
    self.downloadAlertView.isHidden = true
    NSLayoutConstraint.activate([
      self.downloadAlertView.centerXAnchor.constraint(
        equalTo: self.view.centerXAnchor),
      self.downloadAlertView.centerYAnchor.constraint(
        equalTo: self.view.centerYAnchor)
    ])
    self.view.addSubview(self.activityIndicatorView)
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.activityIndicatorView.centerXAnchor.constraint(
        equalTo: self.view.centerXAnchor),
      self.activityIndicatorView.centerYAnchor.constraint(
        equalTo: self.view.centerYAnchor)
    ])
    self.showActivityIndicator(true)
    self.presenter.loadCities()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = true
  }
  
  @objc
  func refreshCitiesList() {
    self.showActivityIndicator(false)
    self.showDownloadAlert(true)
    self.presenter.refreshCitiesList()
  }
  
  func reloadData(animated: Bool) {
    self.showDownloadAlert(false)
    self.showActivityIndicator(animated)
    self.tableView.reloadData()
  }
  
  public func showActivityIndicator(_ isLoading: Bool) {
    DispatchQueue.main.async {
      guard self.downloadAlertView.isHidden == true else {return}
      self.navigationController?.navigationBar.isUserInteractionEnabled = !isLoading
      self.navigationItem.rightBarButtonItem?.isEnabled = !isLoading
      self.navigationItem.setHidesBackButton(isLoading, animated: false)
      self.view.isUserInteractionEnabled = !isLoading
      self.activityIndicatorView.isHidden = !isLoading
      isLoading ? self.activityIndicatorView.startAnimating() : self.activityIndicatorView.stopAnimating()
    }
  }
  
  func showDownloadAlert(_ isLoading: Bool) {
    DispatchQueue.main.async {
      guard self.activityIndicatorView.isHidden == true else {return}
      self.navigationController?.navigationBar.isUserInteractionEnabled = !isLoading
      self.navigationItem.rightBarButtonItem?.isEnabled = !isLoading
      self.navigationItem.setHidesBackButton(isLoading, animated: false)
      self.view.isUserInteractionEnabled = !isLoading
      self.downloadAlertView.isHidden = !isLoading
    }
  }

  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.presenter.tableView(tableView, numberOfRowsInSection: section)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.presenter.tableView(tableView,
                                        reuseIdentifier: self.reuseIdentifier,
                                        cellForRowAt: indexPath)
    return cell
  }
  
  // MARK: - Table view delegate
  
  override func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
    self.presenter.tableView(tableView, didSelectRowAt: indexPath)
  }
}

extension CitiesTableViewController: UISearchBarDelegate {
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    self.presenter.searchCities(with: "")
    searchBar.showsCancelButton = false
    searchBar.text = ""
    searchBar.resignFirstResponder()
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    self.presenter.searchCities(with: searchText)
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = true
  }
}
