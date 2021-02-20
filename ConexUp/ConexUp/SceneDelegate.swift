//
//  SceneDelegate.swift
//  ConexUp
//
//  Created by Mohammed Haque on 1/14/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let loginVC = storyboard.instantiateViewController(withIdentifier: "loginViewController") as? LoginViewController  else {    assertionFailure("Couldn't find login view controller."); return  }
        loginVC.view.alpha = 0.2
        let navigationController = UINavigationController(rootViewController: loginVC)
        
        navigationController.view.addSubview(activityIndicator)
        activityIndicator.centerYAnchor.constraint(equalTo: navigationController.view.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: navigationController.view.centerXAnchor).isActive = true
        navigationController.isNavigationBarHidden = true
        
        self.window?.windowScene = windowScene
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        if Storage.authToken != nil {
            Api.user { (response, error) in
                if let walletData = response {
                    guard let walletVC = storyboard.instantiateViewController(withIdentifier: "walletViewController") as? WalletViewController  else {    assertionFailure("Couldn't find wallet view controller."); return  }
                    let navigationController = UINavigationController(rootViewController: walletVC)
                    navigationController.isNavigationBarHidden = true
                    
                    let rawNum = Storage.phoneNumberInE164
                    let savedUserName = response?["user"] as? [String:Any]
                    let wallet = Wallet.init(data: walletData, ifGenerateAccounts: false)
                    walletVC.rawNum = rawNum ?? ""
                    walletVC.userName = savedUserName?["name"] as? String ?? ""
                    walletVC.wallet = wallet
                    
                    self.window?.windowScene = windowScene
                    self.window?.rootViewController = navigationController
                    self.window?.makeKeyAndVisible()
                    activityIndicator.stopAnimating()
                }
            }
        }
        else {
            loginVC.view.alpha = 1
            activityIndicator.stopAnimating()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

