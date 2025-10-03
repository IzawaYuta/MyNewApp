//
//  MedicineAdditionTableViewCell.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/08/28.
//

import UIKit

class MedicineAdditionTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var medicineName: UITextField!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    var modelId: String = ""
    
    
//    var modelId: String = ""
    
    weak var delegate: MedicineAdditionViewControllerDelegate?
    
    var addedAmount: Int {
        return Int(textField.text ?? "") ?? 0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.keyboardType = .decimalPad
        
        textField.delegate = self
        
        setupTextField()
        doneButton()
        setupCell()
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
    
    private func setupTextField() {
        let textFields: [UITextField] = [medicineName, textField]
        
        for textField in textFields {
            if textField == medicineName {
                textField.adjustsFontSizeToFitWidth = true
                textField.minimumFontSize = 10
                textField.backgroundColor = UIColor.clear
                textField.borderStyle = .none
                textField.isEnabled = false
            } else if textField == textField {
                textField.adjustsFontSizeToFitWidth = true
                textField.minimumFontSize = 15
                textField.backgroundColor = UIColor.white.withAlphaComponent(0.5)
                textField.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
                textField.isEnabled = true
            }
            
        }
    }
    
    private func doneButton() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let closeButton = UIBarButtonItem(title: "閉じる", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [closeButton]
        textField.inputAccessoryView = toolbar
    }
    
    @objc private func dismissKeyboard() {
        textField.resignFirstResponder()
    }
    // 枠線
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // セルの横幅を調整する
        var frame = self.contentView.frame
        frame.size.width = UIScreen.main.bounds.width - 55 // 画面の幅から40ポイント引いたサイズに設定
        frame.origin.x = 5 // 左端から20ポイント内側に配置
        self.contentView.frame = frame
    }
    
    private func setupCell() {
        contentView.layer.borderWidth = 1.5
        contentView.backgroundColor = UIColor.clear
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.cornerRadius = 10.0
    }
}
