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
  let databaseService: DatabaseServiceProtocol = Builder.databaseService

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    self.window = UIWindow(frame: windowScene.coordinateSpace.bounds)
    self.window?.windowScene = windowScene
    self.window?.rootViewController = Builder.buildWeathers()
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

