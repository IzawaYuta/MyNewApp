//
//  MedicineRecordDetailCell.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/07/12.
//

import UIKit

protocol MedicineRecordDetailCellDelegate: AnyObject {
    func didChangeData(for cell: MedicineRecordDetailCell, newTime: Date)
}

class MedicineRecordDetailCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var medicineName: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var unit: UILabel!
    
    weak var delegate: CalendarViewControllerDelegate?
    weak var delegate2: MedicineRecordDetailCellDelegate?
    var inputString: String = "" // 入力中の文字列を保持するためのプロパティ
    
    var selectedTime: Date {
        return timePicker.date
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layoutSubviews()
        setupCell(borderColor: .gray)
        loadTimePickerDate()
        loadTextFieldDate()
        timePicker.addTarget(self, action: #selector(timePickerChanged(_:)), for: .valueChanged) // 値が変更された時のアクションを追加
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // セルの横幅を調整する
        var frame = self.contentView.frame
        frame.size.width = UIScreen.main.bounds.width - 40 // 画面の幅から40ポイント引いたサイズに設定
        frame.origin.x = 20 // 左端から20ポイント内側に配置
        frame.size.height = frame.size.height - 5 // 上下の余白を5ポイントずつ引く
        frame.origin.y = 3 // 上端から3ポイント内側に配置
        self.contentView.frame = frame
    }
    
    func setupCell(borderColor: UIColor) {
        contentView.layer.borderWidth = 1.5
        contentView.layer.borderColor = borderColor.cgColor
        contentView.layer.cornerRadius = 8.0
        contentView.clipsToBounds = true
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    @objc private func timePickerChanged(_ sender: UIDatePicker) {
        saveTimePickerDate(sender.date) // 時間を保存する
        delegate2?.didChangeData(for: self, newTime: sender.date)
    }
    
    private func saveTimePickerDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let timeString = dateFormatter.string(from: date)
        UserDefaults.standard.set(timeString, forKey: "savedTime") // 軽量な永続ストレージ（保存）
    }
    
    private func loadTimePickerDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let timeString = UserDefaults.standard.string(forKey: "savedTime"),
           let savedDate = dateFormatter.date(from: timeString) {
            timePicker.date = savedDate
        } else {
            timePicker.date = Date() // 保存された時間がない場合は現在の時間をセット
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 現在のテキストを取得
        guard let currentText = textField.text else { return true }
        // 新しいテキストを取得
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        // 小数点が2個以上含まれないかチェック
        let decimalCount = newText.components(separatedBy: ".").count - 1
        if decimalCount > 1 {
            return false // 小数点が2個以上の場合は変更を許可しない
        }
        return true
    }
    
    @objc private func textFieldChanged(_ sender: UITextField) {
        if let text = sender.text {
            inputString = text
        }
    }
    
    private func saveTextFieldDate(_ text: Int) {
        UserDefaults.standard.set(text, forKey: "savedText") // 軽量な永続ストレージ（保存）
    }
    
    private func loadTextFieldDate() {
        if let savedText = UserDefaults.standard.value(forKey: "savedText") as? Double {
            // 保存されたテキストを表示形式に応じて整える
            if savedText == Double(Int(savedText)) {
                label.text = "\(Int(savedText))" // 整数として表示
            } else {
                label.text = "\(savedText)" // 小数としてそのまま表示
            }
        } else {
            label.text = "0" // 保存されたテキストがない場合は0を表示
        }
    }
    
    func configure(medicineName: String, timePicker: Date, label: String, unit: String) {
        self.medicineName.text = medicineName
        self.unit.text = unit
        self.timePicker.date = timePicker
        self.label.text = label // textFieldをtextLabelに変更
    }
}
