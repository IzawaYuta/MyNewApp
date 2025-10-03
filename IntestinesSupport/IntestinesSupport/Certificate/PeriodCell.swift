//
//  PeriodCell.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/07/22.
//

import UIKit
import SwiftUI
import RealmSwift

class PeriodCell: UITableViewCell, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var certificateId: String?
    
    let pickerData = ["上旬", "中旬", "下旬"]
    var currentCertificate: CertificateDataModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        
        textField1.delegate = self
        textField2.delegate = self
        textField3.delegate = self
        textField4.delegate = self
        textField5.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        textField1.keyboardType = .numberPad
        textField2.keyboardType = .numberPad
        textField3.keyboardType = .numberPad
        textField4.keyboardType = .numberPad
        textField5.keyboardType = .numberPad
    }
    // 2の倍数かどうかを検知して背景色を変更
    var cellIndex: Int = 0 {
        didSet {
            if cellIndex % 2 != 0 {
                self.backgroundColor = .white
            } else {
                self.backgroundColor = .lightGray.withAlphaComponent(0.1)
            }
        }
    }
    
    @objc func tapDoneButton() {
        self.endEditing(true)
    }
    
    func setDoneButton() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        let commitButton = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(tapDoneButton))
        toolBar.items = [commitButton]
        textField1.inputAccessoryView = toolBar
        textField2.inputAccessoryView = toolBar
        textField3.inputAccessoryView = toolBar
        textField4.inputAccessoryView = toolBar
        textField5.inputAccessoryView = toolBar
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 各フィールドの最大文字数
        let maxMonthLength = 2
        let maxDayLength = 2
        
        // 入力済みの文字と入力された文字を合わせて取得.
        let currentText = (textField.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        // テキストフィールドごとの文字数制限
        switch textField {
        case textField1, textField3, textField5:
            return updatedText.count <= maxMonthLength
        case textField2, textField4:
            return updatedText.count <= maxDayLength
        default:
            return true
        }
    }
    
    struct ContentView: View {
        @State var pickerIndex: Int = 0
        var body: some View {
            Form {
                Section {
                    Picker("季節", selection: $pickerIndex) {
                        Text("上旬").tag(0)
                        Text("中旬").tag(1)
                        Text("下旬").tag(2)
                    }
                    .pickerStyle(.automatic)
                }
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let realm = try! Realm()
        
        guard let id = certificateId else { return }
        
        if let certificate = realm.object(ofType: CertificateDataModel.self, forPrimaryKey: id) {
            // 既存のデータモデルがある場合は更新
            try! realm.write {
                certificate.pickerView = row
                realm.add(certificate, update: .modified)
            }
        } else {
            // 新しいデータモデルを作成し保存
            let newCertificate = CertificateDataModel()
            newCertificate.id = id
            newCertificate.pickerView = row
            
            try! realm.write {
                realm.add(newCertificate)
            }
        }
    }
    
    func loadPickerSelection() {
        let realm = try! Realm()
        // certificateIdの確認
        guard let id = certificateId else {
            return
        }
        // データモデルの読み込み
        if let certificate = realm.object(ofType: CertificateDataModel.self, forPrimaryKey: id) {
            // UIPickerViewの選択状態を設定
            pickerView.selectRow(certificate.pickerView, inComponent: 0, animated: false)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let inputValue = textField.text, let convertedValue = Int(inputValue) else { return }
        
        let realm = try! Realm()
        
        try! realm.write {
            if let id = certificateId {
                // id で既存のデータを検索
                if let certificate = realm.object(ofType: CertificateDataModel.self, forPrimaryKey: id) {
                    // テキストフィールドによって異なるプロパティを更新
                    switch textField {
                    case textField1:
                        certificate.textField1 = convertedValue
                    case textField2:
                        certificate.textField2 = convertedValue
                    case textField3:
                        certificate.textField3 = convertedValue
                    case textField4:
                        certificate.textField4 = convertedValue
                    case textField5:
                        certificate.textField5 = convertedValue
                    default:
                        break
                    }
                } else {
                    // データが存在しない場合は新規作成
                    let newCertificate = CertificateDataModel()
                    newCertificate.id = id // 既存の ID を設定
                    // テキストフィールドによって異なるプロパティを設定
                    switch textField {
                    case textField1:
                        newCertificate.textField1 = convertedValue
                    case textField2:
                        newCertificate.textField2 = convertedValue
                    case textField3:
                        newCertificate.textField3 = convertedValue
                    case textField4:
                        newCertificate.textField4 = convertedValue
                    case textField5:
                        newCertificate.textField5 = convertedValue
                    default:
                        break
                    }
                    realm.add(newCertificate, update: .modified)
                }
            }
        }
    }
}
