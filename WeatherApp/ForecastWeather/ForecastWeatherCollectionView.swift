//
//  ForecastWeatherCollectionView.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 21.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

class ForecastWeatherCollectionView: UICollectionView {
  
  private let itemMargin: CGFloat = 20
  
  init() {
    let collectionViewLayout = UICollectionViewFlowLayout()
    super.init(frame: .zero, collectionViewLayout: collectionViewLayout)
    self.configureUI()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.configureUI()
  }
  
  private func configureUI() {
    let collectionViewLayout = LeftCollectionViewLayout()
    collectionViewLayout.minimumLineSpacing = self.itemMargin
    collectionViewLayout.sectionInset = .init(top: 0,
                                              left: self.itemMargin,
                                              bottom: 0,
                                              right: self.itemMargin)
    collectionViewLayout.scrollDirection = .horizontal
    self.collectionViewLayout = collectionViewLayout
    self.backgroundColor = .systemGray3
    self.translatesAutoresizingMaskIntoConstraints = false
    self.isUserInteractionEnabled = true
     
    self.register(UINib(nibName: String(describing: ForecastWeatherViewCell.self),
                        bundle: nil),
                  forCellWithReuseIdentifier: ForecastWeatherViewCell.cellIdentifier)
   }

}
