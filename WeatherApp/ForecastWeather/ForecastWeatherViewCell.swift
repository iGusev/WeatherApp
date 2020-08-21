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
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.layer.cornerRadius = 15
    self.layer.masksToBounds = true
    self.contentView.addSubview(self.dateLabel)
    self.contentView.addSubview(self.weatherIconView)
    self.contentView.addSubview(self.dayTemperatureLabel)
    self.contentView.addSubview(nightTemperatureLabel)
  }
  
  public func configure(with model: ForecastWeatherViewModel) {
    self.dateLabel.text = model.date
    self.weatherIconView.image = model.weatherIcon
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
