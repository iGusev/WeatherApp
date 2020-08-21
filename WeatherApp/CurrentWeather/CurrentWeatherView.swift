//
//  CurrentWeatherView.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 21.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

class CurrentWeatherView: UIView {
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var currentDateLabel: UILabel!
  @IBOutlet weak var weatherIcon: UIImageView!
  @IBOutlet weak var currentTemperatureLabel: UILabel!
  @IBOutlet weak var weatherDetailsView: UIStackView!
  
  private var weatherDescriptionLabel: UILabel?
  private var feelsLikeLabel: UILabel?
  private var pressureLabel: UILabel?
  private var humidityLabel: UILabel?
  private var uvIndexLabel: UILabel?
  private var windSpeedLabel: UILabel?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    nibSetup()
    configureUI()
  }
   
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    nibSetup()
    configureUI()
  }
   
  func nibSetup() {
    Bundle.main.loadNibNamed(String(describing: CurrentWeatherView.self), owner: self, options: nil)
    self.addSubview(self.contentView)
    self.contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
      self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
  }

  
  public func configure(with model: CurrentWeatherViewModel) {
    self.currentDateLabel.text = model.date
    self.weatherIcon.image = model.weatherIcon
    self.currentTemperatureLabel.text = model.temp
    self.weatherDescriptionLabel?.text = model.weatherDescription
    self.feelsLikeLabel?.text = "Ощущается как \(model.feelsLike)"
    self.pressureLabel?.text = "Давление \(model.pressure)"
    self.humidityLabel?.text = "Влажность воздуха \(model.humidity)"
    self.windSpeedLabel?.text = "Скорость ветра \(model.windSpeed)"
    self.uvIndexLabel?.text = "УФ-индекс \(model.uvIndex)"
    self.weatherDetailsView.setNeedsLayout()
  }
  
  private func configureUI() {
    self.configureWeatherDescriptionLabel()
    self.configureFeelsLikeLabel()
    self.configurePressureLabel()
    self.configureHumidityLabel()
    self.configureWindSpeedLabel()
    self.configureUVIndexLabel()
   }
   
  private func configureWeatherDescriptionLabel() {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 22)
//    label.translatesAutoresizingMaskIntoConstraints = false

    self.weatherDetailsView.addArrangedSubview(label)
    self.weatherDescriptionLabel = label
  }
   
  private func configureFeelsLikeLabel() {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18)
//    label.translatesAutoresizingMaskIntoConstraints = false

    self.weatherDetailsView.addArrangedSubview(label)
    self.feelsLikeLabel = label
  }
   
  private func configurePressureLabel() {
   let label = UILabel()
   label.font = UIFont.systemFont(ofSize: 18)
//   label.translatesAutoresizingMaskIntoConstraints = false

    self.weatherDetailsView.addArrangedSubview(label)
    self.pressureLabel = label
  }
  
  private func configureHumidityLabel() {
   let label = UILabel()
   label.font = UIFont.systemFont(ofSize: 18)
//   label.translatesAutoresizingMaskIntoConstraints = false

   self.weatherDetailsView.addArrangedSubview(label)
    self.humidityLabel = label
  }
  
  private func configureWindSpeedLabel() {
   let label = UILabel()
   label.font = UIFont.systemFont(ofSize: 18)
//   label.translatesAutoresizingMaskIntoConstraints = false

   self.weatherDetailsView.addArrangedSubview(label)
    self.windSpeedLabel = label
  }
  
  private func configureUVIndexLabel() {
   let label = UILabel()
   label.font = UIFont.systemFont(ofSize: 18)
//   label.translatesAutoresizingMaskIntoConstraints = false

   self.weatherDetailsView.addArrangedSubview(label)
    self.uvIndexLabel = label
  }
}
