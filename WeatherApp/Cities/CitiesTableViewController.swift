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
    self.searchBar = UISearchBar()
    self.searchBar?.placeholder = "Введите название города"
    self.searchBar?.delegate = self
    self.searchBar?.barTintColor = .systemGray3
    self.searchBar?.tintColor = .systemIndigo
    self.searchBar?.searchTextField.backgroundColor = .white
    self.tableView.tableHeaderView = self.searchBar
    self.searchBar?.sizeToFit()
    self.presenter.loadCities()
  }
  
  func reloadData() {
    self.tableView.reloadData()
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

}

extension CitiesTableViewController: UISearchBarDelegate {
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = false
    searchBar.text = ""
    searchBar.resignFirstResponder()
    self.presenter.searchCities(with: "")
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    self.presenter.searchCities(with: searchText)
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = true
  }
}
