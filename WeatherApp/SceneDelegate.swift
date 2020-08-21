//
//  SceneDelegate.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 16.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  let databaseService: DatabaseServiceProtocol = CoreDataStack()

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    self.window = UIWindow(frame: windowScene.coordinateSpace.bounds)
    self.window?.windowScene = windowScene
//    let builder = Builder()
//    self.window?.rootViewController = builder.build()
    let presenter = WeatherPresenter(networkService: NetworkService(), databaseService: databaseService, locationService: LocationService())
    let vc = WeatherViewController(presenter: presenter)
    self.window?.rootViewController = vc
    presenter.viewController = vc
    self.window?.makeKeyAndVisible()
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    self.databaseService.save()
  }

  func sceneWillResignActive(_ scene: UIScene) {
    self.databaseService.save()
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    self.databaseService.save()
  }


}

