//
//  NetworkService.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation

protocol NetworkServiceProtocol {
  func getWeather(latitude: Double,
                  longitude: Double,
                  completion: @escaping (Result<[String: Any]?,Error>) -> Void)
  
  func getCities(completion: @escaping (Result<[[String: Any]]?,Error>) -> Void)
  
  func loadIcon(byUrl url: String, completion: @escaping (Result<Data?,Error>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
  
  private let baseURL: String = "https://api.openweathermap.org/data/2.5/onecall"
  private let citiesURL: String = "http://bulk.openweathermap.org/sample/city.list.json.gz"
  private let baseImageURL: String = "http://openweathermap.org/img/wn/"
  private let apiKey: String = "772673b3efd53c9a74c8a5c6ec2fea33"
  
  /// Получение данных о погоде из сети по координатам локации
  /// - Parameters:
  ///   - latitude: широта локации
  ///   - longitude: долгота локаци
  ///   - completion: блок с ответом от сервера
  public func getWeather(latitude: Double,
                  longitude: Double,
                  completion: @escaping (Result<[String: Any]?,Error>) -> Void) {
    
    var urlComponents = URLComponents(string: self.baseURL)
    
    urlComponents?.queryItems = [
      URLQueryItem(name: "lat", value: "\(latitude)"),
      URLQueryItem(name: "lon", value: "\(longitude)"),
      URLQueryItem(name: "exclude", value: "minutely,hourly"),
      URLQueryItem(name: "units", value: "metric"),
      URLQueryItem(name: "lang", value: "ru"),
      URLQueryItem(name: "appid", value: self.apiKey)
    ]
    
    let session = URLSession(configuration: .default)
    guard let url = urlComponents?.url else {return}

    DispatchQueue.global().async {
      let dataTask: URLSessionDataTask? = session.dataTask(with: url) { data, response, error in
          if let error = error {
            completion(.failure(error))
          } else if
            let data = data,
            let response = response as? HTTPURLResponse,
            response.statusCode == 200 {
            do {
              let responseObject = (try JSONSerialization.jsonObject(
                with: data,
                options: .allowFragments)) as? [String: Any]
              completion(.success(responseObject))
            } catch {
              completion(.failure(error))
            }
          }
        }
      dataTask?.resume()
    }
  }
  
  
  /// Получение данных о городах
  /// - Parameter completion: блок с ответом от сервера
  public func getCities(completion: @escaping (Result<[[String: Any]]?,Error>) -> Void) {
    
    guard let url: URL = URL(string: self.citiesURL) else {return}
    
    let session = URLSession(configuration: .default)
    
    DispatchQueue.global().async {
      let dataTask: URLSessionDataTask? = session.dataTask(with: url) { data, response, error in
        
          if let error = error {
            completion(.failure(error))
          } else if
            let data = data,
            let response = response as? HTTPURLResponse,
            response.statusCode == 200 {
            do {
              let nsData: NSData = NSData(data: data)
              guard let decompressedData = nsData.gunzipped() else {return}
              let responseObject = (try JSONSerialization.jsonObject(
                with: decompressedData,
                options: .allowFragments)) as? [[String: Any]]
              completion(.success(responseObject))
            } catch {
              completion(.failure(error))
            }
          }
        }
      dataTask?.resume()
    }
  }
  
  
  /// Загрузка изображений с сервера
  /// - Parameters:
  ///   - url: URL изображения
  ///   - completion: блок с ответом от сервера
  func loadIcon(byUrl url: String, completion: @escaping (Result<Data?,Error>) -> Void) {
    
    let postfix: String = "@2x.png"
    
    guard let url: URL = URL(string: self.baseImageURL + url + postfix) else {return}
    let session = URLSession(configuration: .default)
    
    DispatchQueue.global().async {
      let dataTask: URLSessionDataTask? = session.dataTask(with: url) { data, response, error in
          if let error = error {
            completion(.failure(error))
          } else if
            let data = data,
            let response = response as? HTTPURLResponse,
            response.statusCode == 200 {
            completion(.success(data))
          }
        }
      dataTask?.resume()
    }
  }
}
