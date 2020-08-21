//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 16.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {
  
  private let databaseService = CoreDataStack()
  private var currentWeatherView: CurrentWeatherView?
  private var presenter: WeatherPresenter
  private var citiesPresenter: CitiesPresenter {
    return CitiesPresenter(networkService: NetworkService(), databaseService: databaseService)
  }

  // MARK: - Init
   init(presenter: WeatherPresenter) {
     self.presenter = presenter
     super.init(nibName: nil, bundle: nil)
   }
  
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    self.presenter.viewController = self
    self.currentWeatherView = CurrentWeatherView()
    guard let currentWeatherView = self.currentWeatherView else {return}
    self.view.addSubview(currentWeatherView)
    currentWeatherView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      currentWeatherView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      currentWeatherView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      currentWeatherView.topAnchor.constraint(equalTo: self.view.topAnchor),
      currentWeatherView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ])
    self.presenter.loadData()
//    citiesPresenter.loadCities()
  }
  
  public func updateView() {
    guard let viewModel = self.presenter.currentWeatherModel else {return}
    self.currentWeatherView?.configure(with: viewModel)
    self.view.setNeedsLayout()
  }

}

