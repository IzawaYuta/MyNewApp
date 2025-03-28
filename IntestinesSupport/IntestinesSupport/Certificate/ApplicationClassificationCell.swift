//
//  applicationClassificationCell.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/07/21.
//

import UIKit
import RealmSwift

class ApplicationClassificationCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField0: UITextField!
    
    var certificateId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField0.delegate = self
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
    }
    
    @objc func tapDoneButton() {
        self.endEditing(true)
    }
    
    func setDoneButton() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        let commitButton = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(tapDoneButton))
        toolBar.items = [commitButton]
        textField0.inputAccessoryView = toolBar
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, let id = certificateId else { return }
        
        let realm = try! Realm()
        
        if let certificate = realm.object(ofType: CertificateDataModel.self, forPrimaryKey: id) {
            try! realm.write {
                certificate.textField0 = text
            }
        } else {
            // データが存在しない場合は新しく作成
            let newCertificate = CertificateDataModel()
            newCertificate.id = id
            newCertificate.textField0 = text
            try! realm.write {
                realm.add(newCertificate)
            }
        }
    }
}
