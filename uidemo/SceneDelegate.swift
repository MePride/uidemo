//
//  SceneDelegate.swift
//  uidemo
//
//  Created by Pride on 2025/1/5.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            guard let windowScene = (scene as? UIWindowScene) else { return }
            
            let window = UIWindow(windowScene: windowScene)
            
            // 创建图片编辑器并包装在导航控制器中
            let imageEditorVC = ImageEditorViewController()
            let navigationController = UINavigationController(rootViewController: imageEditorVC)
            
            window.rootViewController = navigationController
            self.window = window
            window.makeKeyAndVisible()
        }
}

