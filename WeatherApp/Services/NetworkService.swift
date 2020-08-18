//
//  NetworkService.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation

protocol NetworkService {
  func getWeather(latitude: Double,
                  longitude: Double,
                  completion: @escaping (Result<[String: Any]?,Error>) -> Void)
}

class NetworkServiceImpl: NetworkService {
  
  private let baseURL: String = "https://api.openweathermap.org/data/2.5/onecall"
  private let apiKey: String = "772673b3efd53c9a74c8a5c6ec2fea33"
  
  func getWeather(latitude: Double,
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
    print(url)

    let dataTask: URLSessionDataTask? = session.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(.failure(error))
      } else if
        let data = data,
        let response = response as? HTTPURLResponse,
        response.statusCode == 200 {
        do {
          let responseObject = (try JSONSerialization.jsonObject(with: data)) as? [String: Any]
          completion(.success(responseObject))
        } catch {
          completion(.failure(error))
        }
      }
    }
    
    dataTask?.resume()
  }
}
