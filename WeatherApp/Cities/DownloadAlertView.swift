//
//  DownloadAlertView.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 23.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

class DownloadAlertView: UIView {
  @IBOutlet var contentView: UIView!
  
  override init(frame: CGRect) {
     super.init(frame: frame)
     nibSetup()
   }
    
   required init?(coder aDecoder: NSCoder) {
     super.init(coder: aDecoder)
     nibSetup()
   }
    
   func nibSetup() {
    Bundle.main.loadNibNamed(String(describing: DownloadAlertView.self), owner: self, options: nil)
    self.addSubview(self.contentView)
    self.contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
      self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
    self.layer.cornerRadius = 20
    self.layer.masksToBounds = true
    self.contentView.setNeedsLayout()
    self.invalidateIntrinsicContentSize()
   }
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: self.contentView.frame.width,
                  height: self.contentView.frame.height)
  }

}
