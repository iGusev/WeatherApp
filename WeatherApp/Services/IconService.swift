//
//  IconService.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 22.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

protocol IconServiceProtocol {
  func icon(byUrl url: String, completion: @escaping (UIImage?, Error?) -> Void)
}

final class IconService: IconServiceProtocol {
  
  private let networkService: NetworkServiceProtocol

  //30 дней
  private let cacheLifeTime: TimeInterval = 30 * 24 * 60 * 60
  
  private let pathName: String = {
    let pathName = "images"
    guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return pathName }
    let url = cachesDirectory.appendingPathComponent(pathName, isDirectory: true)
    
    if !FileManager.default.fileExists(atPath: url.path) {
      try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
    return pathName
  }()
  
  private var images = [String: UIImage]()
  
  /// Инициализатор
  /// - Parameter networkService: сервис для загрузки данных из сети
  init(networkService: NetworkServiceProtocol) {
    self.networkService = networkService
  }
  
  /// Возвращает изображение из кэша при наличии, при отсутствии изображения в кэше производится загрузка из сети
  /// - Parameters:
  ///   - url: URL изображения
  ///   - completion: блок с изображением или возникшей ощибкой
  public func icon(byUrl url: String, completion: @escaping (UIImage?, Error?) -> Void) {
    if let photo = self.images[url] {
      completion(photo, nil)
    } else if let photo = self.getImageFromCache(url: url) {
      completion(photo, nil)
    } else {
      self.loadIcon(byUrl: url) { photo, error in
        completion(photo, error)
      }
    }
  }
  
  private func getFilePath(url: String) -> String? {
    guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory,
                                                         in: .userDomainMask).first
      else { return nil }
    let hashName = url.split(separator: "/").last ?? "default"
    return cachesDirectory.appendingPathComponent(self.pathName + "/" + hashName).path
  }
  
  private func saveImageToCache(url: String, image: UIImage) {
    guard let fileName = self.getFilePath(url: url),
    let data = image.pngData() else { return }
    FileManager.default.createFile(atPath: fileName, contents: data, attributes: nil)
  }
  
  private func getImageFromCache(url: String) -> UIImage? {
    guard
      let fileName = self.getFilePath(url: url),
      let info = try? FileManager.default.attributesOfItem(atPath: fileName),
      let modificationDate = info[FileAttributeKey.modificationDate] as? Date
      else { return nil }
    
    let lifeTime = Date().timeIntervalSince(modificationDate)
    
    guard
      lifeTime <= self.cacheLifeTime,
      let image = UIImage(contentsOfFile: fileName) else { return nil }

    DispatchQueue.main.async {
      self.images[url] = image
    }
    return image
  }
  
  private func loadIcon(byUrl url: String,
                        completion: @escaping (UIImage?, Error?) -> Void) {
    DispatchQueue.global().async {
      self.networkService.loadIcon(byUrl: url) { [weak self] result in
        guard let self = self else {return}
        switch result {
        case .success(let data):
          guard
            let data = data,
            let image = UIImage(data: data) else { return }
          DispatchQueue.main.async {
            self.images[url] = image
          }
          self.saveImageToCache(url: url, image: image)
          completion(image, nil)
        case .failure(let error):
          completion(nil, error)
        }
      }
    }
  }
}
