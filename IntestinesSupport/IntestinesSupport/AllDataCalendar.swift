//
//  AllDataCalendar.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2025/02/05.
//

import UIKit

class AllDataCalendarViewController: UIViewController, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    
    let calendar = UICalendarView()
    var events: [Date: String] = [:] // 日付ごとのイベント情報
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        
        view.backgroundColor = .white
        
        // カレンダーの設定
        calendar.delegate = self
        calendar.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
        calendar.translatesAutoresizingMaskIntoConstraints = false
        
        // カレンダーをビューに追加
        view.addSubview(calendar)
        
        // レイアウト制約を設定
        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            calendar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - UICalendarViewDelegate
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let date = dateComponents.date else { return nil }
        
        // 日付に関連するイベントがあれば、それを表示
        if let event = events[date] {
            let label = UILabel()
            label.text = event
            label.font = UIFont.systemFont(ofSize: 7)
            label.textColor = .systemBlue
            
            return .customView {
                return label
            }
        }
        
        return nil
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        return
    }
    
}

