//
//  TabBarViewController.swift
//  PillCare
//
//  Created by Moin Janjua on 13/08/2024.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    let plusButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

//        setupPlusButton()
        self.delegate = self
        
       
        let appearance = UITabBarAppearance()

             // Customize selected icon and label color
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemRed
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemRed]

             // Customize unselected icon and label color
             appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
             appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
             
             // Apply the appearance configuration to the tab bar
             tabBar.standardAppearance = appearance
         
        
//        updateTabBarImages()
    }

    
    func updateTabBarImages() {
        guard let items = tabBar.items else { return }
        
       
        for (index, item) in items.enumerated() {
          
            item.setTitleTextAttributes([.foregroundColor: UIColor.systemRed], for: .selected)
            item.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
            
            
        }
    }

    
//    func setupPlusButton() {
//        plusButton.frame.size = CGSize(width: 60, height: 60)
//        plusButton.layer.cornerRadius = plusButton.frame.size.width / 2
//        plusButton.backgroundColor = UIColor.systemPink // Customize the color
//        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
//        plusButton.tintColor = .white
//        plusButton.layer.shadowRadius = 5
//        plusButton.layer.shadowOpacity = 0.7
//        plusButton.layer.shadowOffset = CGSize(width: 0, height: 0)
//        plusButton.layer.shadowColor = UIColor.black.cgColor
//        
//        plusButton.center = CGPoint(x: tabBar.center.x, y: tabBar.frame.origin.y - 50)
//    
//        view.addSubview(plusButton)
//
//        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
//    }
//
//    @objc func plusButtonTapped() {
//        
//        animatePlusButton()
//        // Assuming you have a view controller you want to navigate to
//        let customTabBar = CustomTabBar()
//        customTabBar.MoveplusButtonScreen()
//      
//    }
    
//    private func animatePlusButton() {
//        // First scale up (bounce effect)
//        UIView.animate(withDuration: 0.2, animations: {
//            self.plusButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) // scale up
//        }) { _ in
//            // Then scale down (return to slightly smaller size)
//            UIView.animate(withDuration: 0.2, animations: {
//                self.plusButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9) // scale down slightly
//            }) { _ in
//                // Finally, bring it back to normal size
//                UIView.animate(withDuration: 0.2) {
//                    self.plusButton.transform = .identity // return to original size
//                }
//            }
//        }
//    }

    // UITabBarControllerDelegate method to detect the selected tab bar item
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController),
           let customTabBar = self.tabBar as? CustomTabBar {
           
            customTabBar.updateLinePosition(selectedIndex: selectedIndex)
            
        }
    }
}
