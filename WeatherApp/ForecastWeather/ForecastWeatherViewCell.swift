//
//  ForecastWeatherViewCell.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 21.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

class ForecastWeatherViewCell: UICollectionViewCell {
  
  static let cellIdentifier = "ForecastWeatherCell"
  
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var weatherIconView: UIImageView!
  @IBOutlet weak var dayTemperatureLabel: UILabel!
  @IBOutlet weak var nightTemperatureLabel: UILabel!
  
  private var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.layer.cornerRadius = 20
    self.layer.masksToBounds = true
    self.contentView.backgroundColor = .systemGray2
    self.contentView.addSubview(self.dateLabel)
    self.contentView.addSubview(self.weatherIconView)
    self.weatherIconView.addSubview(self.activityIndicatorView)
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.activityIndicatorView.centerXAnchor.constraint(
        equalTo: self.weatherIconView.centerXAnchor),
      self.activityIndicatorView.centerYAnchor.constraint(
        equalTo: self.weatherIconView.centerYAnchor)
    ])
    self.contentView.addSubview(self.dayTemperatureLabel)
    self.contentView.addSubview(nightTemperatureLabel)
  }
  
  public func configure(with model: ForecastWeatherViewModel) {
    self.dateLabel.text = model.date
    if let weatherIcon = model.weatherIcon {
      self.weatherIconView.image = weatherIcon
      self.activityIndicatorView.isHidden = true
      self.activityIndicatorView.stopAnimating()
    } else {
      self.activityIndicatorView.isHidden = false
      self.activityIndicatorView.startAnimating()
    }
    self.dayTemperatureLabel.text = "\(model.tempDay)\u{00B0}C"
    self.nightTemperatureLabel.text = "\(model.tempNight)\u{00B0}C"
  }
  
  override func prepareForReuse() {
    self.dateLabel.text = nil
    self.weatherIconView.image = nil
    self.dayTemperatureLabel.text = nil
    self.nightTemperatureLabel.text = nil
  }
}
