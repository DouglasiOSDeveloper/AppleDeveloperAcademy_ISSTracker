//
//  TabBar.swift
//  Nano7App
//
//  Created by Luiz Araujo on 17/11/21.
//

import UIKit

class TabBar: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
           UITabBar.appearance().barTintColor = .systemBackground
           tabBar.tintColor = .label
           setupVCs()
    }
    
    
    func setupVCs() {
        viewControllers = [
            createNavController(for: ViewController(), title: NSLocalizedString("Track", comment: ""), image: UIImage(named: "tab-icon-sat")!),
            createNavController(for: FavoritosViewController(), title: NSLocalizedString("Favoritos", comment: ""), image: UIImage(systemName: "star")!),
            createNavController(for: ConfiguracaoViewController(), title: NSLocalizedString("Configuração", comment: ""), image: UIImage(systemName: "gearshape")!)
        ]
    }
    
    
    //Se precisar criar um navigationController
    fileprivate func createNavController(for rootViewController: UIViewController,
                                         title: String,
                                         image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        
        return navController
    }
    
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
