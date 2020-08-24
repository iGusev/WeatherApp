//
//  UIViewController+Ext.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 23.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

//Показ модального окна с ошибкой
extension UIViewController {
  func showAlert(error: Error, handler: ((UIAlertAction) -> Void)? = nil) {
    DispatchQueue.main.async {
      let alertVC = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
      
      alertVC.addAction(UIAlertAction(title: "ОК", style: .default, handler: handler))
      self.present(alertVC, animated: true, completion: nil)
    }
  }
}
