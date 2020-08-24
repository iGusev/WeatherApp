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
  @IBOutlet weak var locationButton: UIButton!
  @IBOutlet weak var currentDateLabel: UILabel!
  @IBOutlet weak var weatherIcon: UIImageView!
  @IBOutlet weak var currentTemperatureLabel: UILabel!
  @IBOutlet weak var weatherDetailsView: UIStackView!
  
  private var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
  private var weatherDescriptionLabel: UILabel?
  private var feelsLikeLabel: UILabel?
  private var pressureLabel: UILabel?
  private var humidityLabel: UILabel?
  private var uvIndexLabel: UILabel?
  private var windSpeedLabel: UILabel?
  
  private var onButtonTap: (() -> Void)?
  
  //MARK: - Init
  init(frame: CGRect, onButtonTap: @escaping (() -> Void)) {
    self.onButtonTap = onButtonTap
    super.init(frame: frame)
    nibSetup()
    configureUI()
  }
   
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    nibSetup()
    configureUI()
  }
  
  private func nibSetup() {
    let name = String(describing: type(of: self))
    let nib = UINib(nibName: name, bundle: nil)
    nib.instantiate(withOwner: self, options: nil)
    
    self.addSubview(self.contentView)
    self.contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
      self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
  }

  //MARK: - Configuration with data
  /// Настройка с данными модели
  /// - Parameter model: модель данных
  public func configure(with model: CurrentWeatherViewModel) {
    self.currentDateLabel.text = model.date
    if let weatherIcon = model.weatherIcon {
      self.weatherIcon.image = weatherIcon
      self.activityIndicatorView.isHidden = true
      self.activityIndicatorView.stopAnimating()
    } else {
      self.activityIndicatorView.isHidden = false
      self.activityIndicatorView.startAnimating()
    }
    if let city = model.city {
      self.locationButton.setTitle("\(city)", for: .normal)
    }
    self.locationButton.isHidden = false
    self.currentTemperatureLabel.text = "\(model.temp)\u{00B0}C"
    self.weatherDescriptionLabel?.text = model.weatherDescription
    self.feelsLikeLabel?.text = "Ощущается как \(model.feelsLike)\u{00B0}C"
    self.pressureLabel?.text = "Давление \(model.pressure) мм рт. ст."
    self.humidityLabel?.text = "Влажность воздуха \(model.humidity)%"
    self.windSpeedLabel?.text = "Скорость ветра \(model.windSpeed) м/с"
    self.uvIndexLabel?.text = "УФ-индекс \(model.uvIndex)"
    self.contentView.setNeedsLayout()
    self.contentView.layoutIfNeeded()
  }
  
  ///Настройка пустого вью
  /// - Parameter today: текущая дата
  public func configureWithEmptyData(today: String) {
    self.currentDateLabel.text = today
    self.activityIndicatorView.isHidden = false
    self.activityIndicatorView.startAnimating()
    self.locationButton.isHidden = false
    self.currentTemperatureLabel.text = "Температура"
    self.weatherDescriptionLabel?.text = "Погодные условия"
    self.feelsLikeLabel?.text = "Ощущается как ..."
    self.pressureLabel?.text = "Давление, мм рт. ст."
    self.humidityLabel?.text = "Влажность воздуха, %"
    self.windSpeedLabel?.text = "Скорость ветра, м/с"
    self.uvIndexLabel?.text = "УФ-индекс"
    self.contentView.setNeedsLayout()
    self.contentView.layoutIfNeeded()
  }
  
  
  /// Действие по нажатию кнопки выбора местоположения
  @IBAction func locationButtonOnTap(_ sender: Any) {
    guard let action = self.onButtonTap else {return}
    action()
  }
  
  //MARK: - UI configuration
  private func configureUI() {
    self.currentDateLabel.text = nil
    self.currentTemperatureLabel.text = nil
    self.weatherIcon.addSubview(self.activityIndicatorView)
    
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.activityIndicatorView.centerXAnchor.constraint(
        equalTo: self.weatherIcon.centerXAnchor),
      self.activityIndicatorView.centerYAnchor.constraint(
        equalTo: self.weatherIcon.centerYAnchor)
    ])
    
    self.configureLocationButton()
    self.configureWeatherDescriptionLabel()
    self.configureFeelsLikeLabel()
    self.configurePressureLabel()
    self.configureHumidityLabel()
    self.configureWindSpeedLabel()
    self.configureUVIndexLabel()
   }
  
  private func configureLocationButton() {
    self.locationButton.setTitle("Текущее местоположение", for: .normal)
    self.locationButton.layer.cornerRadius = 10
    self.locationButton.layer.masksToBounds = true
    self.locationButton.layer.borderColor = UIColor.systemIndigo.cgColor
    self.locationButton.layer.borderWidth = 1
    self.locationButton.isHidden = true
  }
   
  private func configureWeatherDescriptionLabel() {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 22)
    label.backgroundColor = .systemGray3
    
    self.weatherDetailsView.addArrangedSubview(label)
    self.weatherDescriptionLabel = label
  }
   
  private func configureFeelsLikeLabel() {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18)
    label.textColor = .systemIndigo
    label.backgroundColor = .systemGray3

    self.weatherDetailsView.addArrangedSubview(label)
    self.feelsLikeLabel = label
  }
   
  private func configurePressureLabel() {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18)
    label.textColor = .systemIndigo
    label.backgroundColor = .systemGray3

    self.weatherDetailsView.addArrangedSubview(label)
    self.pressureLabel = label
  }
  
  private func configureHumidityLabel() {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18)
    label.textColor = .systemIndigo
    label.backgroundColor = .systemGray3

    self.weatherDetailsView.addArrangedSubview(label)
    self.humidityLabel = label
  }
  
  private func configureWindSpeedLabel() {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18)
    label.textColor = .systemIndigo
    label.backgroundColor = .systemGray3

    self.weatherDetailsView.addArrangedSubview(label)
    self.windSpeedLabel = label
  }
  
  private func configureUVIndexLabel() {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18)
    label.textColor = .systemIndigo
    label.backgroundColor = .systemGray3
      
    self.weatherDetailsView.addArrangedSubview(label)
    self.uvIndexLabel = label
  }
}
