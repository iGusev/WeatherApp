//
//  ViewController.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 16.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  private var presenter: WeatherPresenter = WeatherPresenter(networkService: NetworkService(), databaseService: CoreDataStack(), locationService: LocationService())

  override func viewDidLoad() {
    super.viewDidLoad()
    presenter.loadData()
  }


}

