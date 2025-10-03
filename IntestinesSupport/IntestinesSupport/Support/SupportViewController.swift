//
//  SupportViewController.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/10/14.
//

import Foundation
import UIKit
import MessageUI

class SupportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let tableViewCell = [/*"Empty1TableViewCell", "ColorTableViewCell",*/"Empty2TableViewCell",  "NotificationSettingsTableViewCell", "Empty3TableViewCell", "SupportTableViewCell", "PrivacyPolicyTableViewCell"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // スクロールを無効化
        tableView.isScrollEnabled = false
        
        tableView.register(UINib(nibName: "Empty1TableViewCell", bundle: nil), forCellReuseIdentifier: "Empty1TableViewCell")
        tableView.register(UINib(nibName: "ColorTableViewCell", bundle: nil), forCellReuseIdentifier: "ColorTableViewCell")
        tableView.register(UINib(nibName: "Empty2TableViewCell", bundle: nil), forCellReuseIdentifier: "Empty2TableViewCell")
        tableView.register(UINib(nibName: "NotificationSettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationSettingsTableViewCell")
        tableView.register(UINib(nibName: "Empty3TableViewCell", bundle: nil), forCellReuseIdentifier: "Empty3TableViewCell")
        tableView.register(UINib(nibName: "SupportTableViewCell", bundle: nil), forCellReuseIdentifier: "SupportTableViewCell")
        tableView.register(UINib(nibName: "PrivacyPolicyTableViewCell", bundle: nil), forCellReuseIdentifier: "PrivacyPolicyTableViewCell")
        
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true // Aに戻るたびに非表示
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = tableViewCell[indexPath.row]
        
        if identifier == "Empty1TableViewCell" {
            let empty1TableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! Empty1TableViewCell
            empty1TableViewCell.selectionStyle = .none // 選択スタイルを無効にする
            return empty1TableViewCell
        }
        if identifier == "ColorTableViewCell" {
            let colorTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ColorTableViewCell
            colorTableViewCell.selectionStyle = .none // 選択スタイルを無効にする
            return colorTableViewCell
        } else if identifier == "Empty2TableViewCell" {
            let empty2TableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! Empty2TableViewCell
            empty2TableViewCell.selectionStyle = .none // 選択スタイルを無効にする
            return empty2TableViewCell
        } else if identifier == "NotificationSettingsTableViewCell" {
            let notificationSettingsTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NotificationSettingsTableViewCell
            notificationSettingsTableViewCell.selectionStyle = .none // 選択スタイルを無効にする
            notificationSettingsTableViewCell.delegate = self
            return notificationSettingsTableViewCell
        } else if identifier == "Empty3TableViewCell" {
                let empty3TableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! Empty3TableViewCell
                empty3TableViewCell.selectionStyle = .none // 選択スタイルを無効にする
                return empty3TableViewCell
        } else if identifier == "SupportTableViewCell" {
            let supportTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SupportTableViewCell
            supportTableViewCell.selectionStyle = .none // 選択スタイルを無効にする
            return supportTableViewCell
        } else if identifier == "PrivacyPolicyTableViewCell" {
            let privacyPolicyTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PrivacyPolicyTableViewCell
            privacyPolicyTableViewCell.selectionStyle = .none // 選択スタイルを無効にする
            return privacyPolicyTableViewCell
        }
        return UITableViewCell()
        
    }
}

// MARK: Delegate関係
extension SupportViewController: NotificationSettingsTableViewCellDelegate {
    
    // 行の高さを設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let identifier = tableViewCell[indexPath.row]
        if identifier == "Empty1TableViewCell" {
            return 25
        } else if identifier == "Empty2TableViewCell" {
            return 60
        } else if identifier == "Empty3TableViewCell" {
            return 60
            
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルタップ時の色を変えないようにする
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        // セルの identifier を取得
        let identifier = tableViewCell[indexPath.row]
        
        // 各セルの identifier に応じて URL を設定
        var urlString: String?
        if identifier == "SupportTableViewCell" {
            urlString = "https://intestinessupport.hp.peraichi.com/?_gl=1*awdhas*_gcl_au*MjAzNjk2ODY0OC4xNzI4Njk0NzMy&_ga=2.221421852.562715736.1728904895-1236405149.1728694732"
        } else if identifier == "PrivacyPolicyTableViewCell" {
            urlString = "https://wooded-starburst-67e.notion.site/11ce36f7a27180ed9311d9209fa8237b"
        } else if identifier == "NotificationSettingsTableViewCell" {
            // 設定画面へ遷移
            if let urlString = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(urlString, options: [:], completionHandler: nil)
            }
        }
        
        // URLを開く処理
        if let urlString = urlString, let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // TODO: 通知の説明をいれる
    func didTapedButton(in cell: NotificationSettingsTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let alert = UIAlertController(
            title: "説明",
            message: "セル \(indexPath.row + 1) の簡易説明です。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
}
