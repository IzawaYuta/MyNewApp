//
//  CalendarDateCell.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/07/11.
//

import UIKit
import FSCalendar
import SwiftUI

class CalendarDateCell: UITableViewCell {
    
    @IBOutlet weak var calendarDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dateForMatter()
        
    }
    private func dateForMatter() {
        // 日付の初期表示設定（現在の日付）
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy年MM月dd日(EEE)"
        let currentDate = Date()
        let currentDateText = dateFormatter.string(from: currentDate)
        calendarDate.text = currentDateText
    }
    func configure(with date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy年MM月dd日(EEE)"
        let dateString = dateFormatter.string(from: date)
        calendarDate.text = dateString
    }
}
//    @objc private func updateLabelColor(_ notification: Notification) {
//        if let color = notification.userInfo?["color"] as? UIColor {
//            
//            var red: CGFloat = 0
//            var green: CGFloat = 0
//            var blue: CGFloat = 0
//            var alpha: CGFloat = 0
//            
//            if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
//                print("\(color)")
//                if red == 0 && green == 0 && blue == 0 && alpha == 1 {
//                    calendarDate.textColor = .white
//                    // TODO: テキストが見にくいと感じたらコメントアウト外す
//                    //                } else if red == 0.5 && green == 0.5 && blue == 1.0 && alpha == 1.0 {
//                    //                    calendarDate.textColor = .white
//                } else {
//                    calendarDate.textColor = .black
//                }
//            }
//            calendarDate.backgroundColor = color
//            saveColorToUserDefaults(color)
//        }
//        calendarDate.setNeedsDisplay()
//    }
//    
//    deinit {
//        // 通知の解除
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    private func saveColorToUserDefaults(_ color: UIColor) {
//        // UIColor を Data に変換して保存
//        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) {
//            UserDefaults.standard.set(colorData, forKey: "savedColor")
//        }
//    }
//}
//extension Notification.Name {
//    static let didChangeColor = Notification.Name("didChangeColor")
//}
