//
//  TabViewController.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/07/05.
//

import Foundation
import UIKit

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        UITabBar.appearance().tintColor = UIColor.black
        
        UITabBar.appearance().unselectedItemTintColor = UIColor.systemGray
        
        UITabBar.appearance().backgroundColor = UIColor(red: 0.4, green: 0.7, blue: 0.4, alpha: 0.2)
        
        loadSavedTabBarColor()
        loadDefaultTintColor()
        loadTintColor()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func loadSavedTabBarColor() {
        if let saveColorData = UserDefaults.standard.array(forKey: "tabBarColor") as? [CGFloat], saveColorData.count == 4 {
            let backColor = UIColor(red: saveColorData[0], green: saveColorData[1], blue: saveColorData[2], alpha: saveColorData[3])
            
            self.tabBar.backgroundColor = backColor
        }
    }
    func loadDefaultTintColor() {
        if let saveColorData = UserDefaults.standard.array(forKey: "defaultTintColor") as? [CGFloat], saveColorData.count == 4 {
            let unselectedItemTintColor = UIColor(red: saveColorData[0], green: saveColorData[1], blue: saveColorData[2], alpha: saveColorData[3])
            
            self.tabBar.unselectedItemTintColor = unselectedItemTintColor
        }
    }
    func loadTintColor() {
        if let saveColorData = UserDefaults.standard.array(forKey: "tintColor") as? [CGFloat], saveColorData.count == 4 {
            let tintColor = UIColor(red: saveColorData[0], green: saveColorData[1], blue: saveColorData[2], alpha: saveColorData[3])
            
            self.tabBar.tintColor = tintColor
        }
    }
}
