//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 16.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {

  private var currentWeatherView: CurrentWeatherView?
  private var forecastWeatherView: ForecastWeatherCollectionView?
  
  private let itemMargin: CGFloat = 20
  
  private var isUpdating: Bool = false
  
  private var presenter: WeatherPresenter

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
    self.configureUI()
    self.presenter.loadData()
  }
  
  private func configureUI() {
    self.view.backgroundColor = .systemGray3
    
    self.currentWeatherView = CurrentWeatherView()
    self.forecastWeatherView = ForecastWeatherCollectionView()
    guard let currentWeatherView = self.currentWeatherView,
          let forecastWeatherView = self.forecastWeatherView else {return}
    self.view.addSubview(currentWeatherView)
    self.view.addSubview(forecastWeatherView)
    
    currentWeatherView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      currentWeatherView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      currentWeatherView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      currentWeatherView.topAnchor.constraint(equalTo: self.view.topAnchor)
    ])
    
    forecastWeatherView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      forecastWeatherView.leadingAnchor.constraint(
        equalTo: self.view.leadingAnchor),
      forecastWeatherView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      forecastWeatherView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      forecastWeatherView.topAnchor.constraint(
        equalTo: currentWeatherView.bottomAnchor, constant: self.itemMargin)
    ])
    
    forecastWeatherView.delegate = self
    forecastWeatherView.dataSource = self
  }
  
  public func updateView() {
//    guard !self.isUpdating else {return}
    guard let currentWeatherViewModel = self.presenter.currentWeatherModel else {return}
    self.isUpdating = true
    self.currentWeatherView?.configure(with: currentWeatherViewModel)
    self.forecastWeatherView?.reloadData()
    self.isUpdating = false
    self.view.setNeedsLayout()
    self.view.layoutIfNeeded()
  }

}

extension WeatherViewController:
          UICollectionViewDelegate,
          UICollectionViewDataSource,
          UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    self.presenter.forecastWeatherModels.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = self.forecastWeatherView?.dequeueReusableCell(
      withReuseIdentifier: ForecastWeatherViewCell.cellIdentifier,
      for: indexPath) as! ForecastWeatherViewCell
    cell.configure(with: self.presenter.forecastWeatherModels[indexPath.item])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let itemWidth = collectionView.frame.width / 3
    return CGSize(width: itemWidth, height: itemWidth)
  }
  
}
