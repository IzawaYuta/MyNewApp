//
//  ColorTableViewCell.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/10/16.
//

import UIKit

class ColorTableViewCell: UITableViewCell {
    
    @IBOutlet weak var colorButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        let green = UIColor(red: 0.4, green: 0.7, blue: 0.4, alpha: 0.2)
        colorButton.backgroundColor = green
        
        loadSavedColorButton()
        
        self.colorButton.layer.borderWidth = 0.5
        self.colorButton.layer.borderColor = UIColor.gray.cgColor
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func colorButtonTapped(_ sender: UIButton) {
        if let tabBarController = self.window?.rootViewController as? UITabBarController {
            let tabBar = tabBarController.tabBar
            
            let red = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
            let blue = UIColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
            let green = UIColor(red: 0.4, green: 0.7, blue: 0.4, alpha: 0.2)
            let yellow = UIColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0)
            let white = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            let black = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            
            // 赤色のUIImageを生成
            func createColorImage(color: UIColor, size: CGSize = CGSize(width: 30, height: 30)) -> UIImage? {
                UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                color.setFill()
                UIRectFill(CGRect(origin: .zero, size: size))
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return image
            }
            
            let redImage = createColorImage(color: red)
            let blueImage = createColorImage(color: blue)
            let greenImage = createColorImage(color: green)
            let yellowImage = createColorImage(color: yellow)
            let whiteImage = createColorImage(color: white)
            let blackImage = createColorImage(color: black)
            
            // メニュー項目を作成
            let menu = UIMenu(children: [
                UIAction(title: "赤", image: redImage, handler: { _ in
                    let red = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
                    let customColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
                    let black = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                    self.colorButton.backgroundColor = red
                    tabBar.backgroundColor = red
                    tabBar.unselectedItemTintColor = customColor
                    tabBar.tintColor = black
                    self.saveTabBarColor(backColor: red)
                    self.saveTabDefaultTintColor(DefaultTintColor: customColor)
                    self.saveTabTintColor(tintColor: black)
                }),
                UIAction(title: "青", image: blueImage, handler: { _ in
                    let blue = UIColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
                    let customColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
                    let black = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                    self.colorButton.backgroundColor = blue
                    tabBar.backgroundColor = blue
                    tabBar.unselectedItemTintColor = customColor
                    tabBar.tintColor = black
                    self.saveTabBarColor(backColor: blue)
                    self.saveTabDefaultTintColor(DefaultTintColor: customColor)
                    self.saveTabTintColor(tintColor: black)
                }),
                UIAction(title: "緑", image: greenImage, handler: { _ in
                    let green = UIColor(red: 0.4, green: 0.7, blue: 0.4, alpha: 0.2)
                    let customColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
                    let black = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                    self.colorButton.backgroundColor = green
                    tabBar.backgroundColor = green
                    tabBar.unselectedItemTintColor = customColor
                    tabBar.tintColor = black
                    self.saveTabBarColor(backColor: green)
                    self.saveTabDefaultTintColor(DefaultTintColor: customColor)
                    self.saveTabTintColor(tintColor: black)
                }),
                UIAction(title: "黄", image: yellowImage, handler: { _ in
                    let yellow = UIColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0)
                    let customColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
                    let black = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                    self.colorButton.backgroundColor = yellow
                    tabBar.backgroundColor = yellow
                    tabBar.unselectedItemTintColor = customColor
                    tabBar.tintColor = black
                    self.saveTabBarColor(backColor: yellow)
                    self.saveTabDefaultTintColor(DefaultTintColor: customColor)
                    self.saveTabTintColor(tintColor: black)
                }),
                UIAction(title: "白", image: whiteImage, handler: { _ in
                    let white = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
                    let customColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
                    let black = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                    self.colorButton.backgroundColor = white
                    tabBar.backgroundColor = white
                    tabBar.unselectedItemTintColor = customColor
                    tabBar.tintColor = black
                    self.saveTabBarColor(backColor: white)
                    self.saveTabDefaultTintColor(DefaultTintColor: customColor)
                    self.saveTabTintColor(tintColor: black)
                }),
                UIAction(title: "黒", image: blackImage, handler: { _ in
                    let black = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                    let customColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4)
                    let white = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    self.colorButton.backgroundColor = black
                    tabBar.backgroundColor = black
                    tabBar.unselectedItemTintColor = customColor
                    tabBar.tintColor = white
                    self.saveTabBarColor(backColor: black)
                    self.saveTabDefaultTintColor(DefaultTintColor: customColor)
                    self.saveTabTintColor(tintColor: white)
                })
            ])
            
            // メニューをボタンに設定
            sender.menu = menu
            sender.showsMenuAsPrimaryAction = true // メニューを表示させる設定
            
        }
    }
    
    func saveTabBarColor(backColor: UIColor) {
        if let backColorComponents = backColor.cgColor.components {
            let colorData: [CGFloat] = [backColorComponents[0], backColorComponents[1], backColorComponents[2], backColorComponents[3]]
            UserDefaults.standard.set(colorData, forKey: "tabBarColor")
        }
    }
    
    func saveTabDefaultTintColor(DefaultTintColor: UIColor) {
        if let tintColorComponents = DefaultTintColor.cgColor.components {
            let colorData: [CGFloat] = [tintColorComponents[0], tintColorComponents[1], tintColorComponents[2], tintColorComponents[3]]
            UserDefaults.standard.set(colorData, forKey: "defaultTintColor")
        }
    }
    
    func saveTabTintColor(tintColor: UIColor) {
        if let tintColorComponents = tintColor.cgColor.components {
            let colorData: [CGFloat] = [tintColorComponents[0], tintColorComponents[1], tintColorComponents[2], tintColorComponents[3]]
            UserDefaults.standard.set(colorData, forKey: "tintColor")
        }
    }
    
    func loadSavedColorButton() {
        if let saveColorData = UserDefaults.standard.array(forKey: "tabBarColor") as? [CGFloat], saveColorData.count == 4 {
            let backColor = UIColor(red: saveColorData[0], green: saveColorData[1], blue: saveColorData[2], alpha: saveColorData[3])
            
            self.colorButton.backgroundColor = backColor
        }
    }
    
//    func changeColor(to color: UIColor) {
//        // NotificationCenterで色を通知
//        NotificationCenter.default.post(name: .didChangeColor, object: nil, userInfo: ["color": color])
//    }
}
