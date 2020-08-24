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
  private var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
  
  private let itemMargin: CGFloat = 20
  
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
    
    self.currentWeatherView = CurrentWeatherView(frame: .zero,
                                                 onButtonTap: {
                                                  self.presenter.locationButtonOnTap()
    })
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
    
    self.view.addSubview(self.activityIndicatorView)
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.activityIndicatorView.centerXAnchor.constraint(
        equalTo: self.view.centerXAnchor),
      self.activityIndicatorView.centerYAnchor.constraint(
        equalTo: self.view.centerYAnchor)
    ])
    self.activityIndicatorView.isHidden = true
  }
  
  public func updateView() {
    DispatchQueue.main.async {
      guard let currentWeatherViewModel = self.presenter.currentWeatherModel else {return}
      self.currentWeatherView?.configure(with: currentWeatherViewModel)
      self.forecastWeatherView?.reloadData()
      self.view.setNeedsLayout()
      self.view.layoutIfNeeded()
      self.showActivityIndicator(false)
    }
  }
  
  public func updateViewWithEmptyData(today: String) {
    DispatchQueue.main.async {
      self.currentWeatherView?.configureWithEmptyData(today: today)
      self.forecastWeatherView?.reloadData()
      self.view.setNeedsLayout()
      self.view.layoutIfNeeded()
      self.showActivityIndicator(false)
    }
  }
  
  public func showActivityIndicator(_ isLoading: Bool) {
    DispatchQueue.main.async {
      self.activityIndicatorView.isHidden = !isLoading
      isLoading ? self.activityIndicatorView.startAnimating() : self.activityIndicatorView.stopAnimating()
    }
  }
  
  public func showNoDataAlert() {
    DispatchQueue.main.async {
      let alertVC = UIAlertController(title: "Уведомление", message: "Для загрузки погодных данных выберите местоположение", preferredStyle: .alert)
      
      alertVC.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
      self.present(alertVC, animated: true, completion: nil)
    }
  }

}

extension WeatherViewController:
          UICollectionViewDelegate,
          UICollectionViewDataSource,
          UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.presenter.forecastWeatherModels.count > 0 ? self.presenter.forecastWeatherModels.count : 7
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = self.forecastWeatherView?.dequeueReusableCell(
      withReuseIdentifier: ForecastWeatherViewCell.cellIdentifier,
      for: indexPath) as! ForecastWeatherViewCell
    if self.presenter.forecastWeatherModels.count == 0 {
      cell.configureWithEmptyData(today: "23.08")
    } else {
      cell.configure(with: self.presenter.forecastWeatherModels[indexPath.item])
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let itemWidth = collectionView.frame.width / 3
    return CGSize(width: itemWidth, height: itemWidth)
  }
  
}
