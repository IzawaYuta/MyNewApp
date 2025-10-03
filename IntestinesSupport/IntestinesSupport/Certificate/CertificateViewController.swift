//
//  Certificate.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/07/03.
//

import Foundation
import UIKit
import RealmSwift

class CertificateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CertificateViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tableViewCell: [String] = []
    var certificateIds: [String] = []
    private var certificateDataModel: [CertificateDataModel] = []
    weak var delegate: CertificateViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.isHidden = true
        tableView
        
        tableView.register(UINib(nibName: "ApplicationClassificationCell", bundle: nil), forCellReuseIdentifier: "ApplicationClassificationCell")
        tableView.register(UINib(nibName: "MoneyCell", bundle: nil), forCellReuseIdentifier: "MoneyCell")
        tableView.register(UINib(nibName: "HierarchyClassificationCell", bundle: nil), forCellReuseIdentifier: "HierarchyClassificationCell")
        tableView.register(UINib(nibName: "DeadlineCell", bundle: nil), forCellReuseIdentifier: "DeadlineCell")
        tableView.register(UINib(nibName: "PeriodCell", bundle: nil), forCellReuseIdentifier: "PeriodCell")
//        tableView.register(UINib(nibName: "PlusButtonCell", bundle: nil), forCellReuseIdentifier: "PlusButtonCell")
        
        tableViewCell = ["ApplicationClassificationCell", "MoneyCell", "HierarchyClassificationCell", "DeadlineCell", "PeriodCell"]
        loadCertificates()
        saveData()
    }
    // 読み込み
    private func loadCertificates() {
        let realm = try! Realm()
        let certificates = realm.objects(CertificateDataModel.self)
        certificateDataModel = Array(certificates)
        certificateIds = certificateDataModel.map { $0.id } // IDの配列を更新
        // 保存されたデータに基づいてPeriodCellを追加
        var periodCellAdded = false
        for _ in certificateDataModel {
            if !periodCellAdded {
                tableViewCell.insert("PeriodCell", at: tableViewCell.count - 1) // PlusButtonCell の直前に追加
                periodCellAdded = true
            }
        }
        tableView.reloadData()
    }
    // 行数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewCell.count
    }
    // 各行の内容を設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = tableViewCell[indexPath.row]
        if identifier == "ApplicationClassificationCell" {
            let applicationClassificationCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ApplicationClassificationCell
            if indexPath.row < certificateDataModel.count {
                let data = certificateDataModel[indexPath.row]
                // 各フィールドにデータを設定
                applicationClassificationCell.textField0.text = data.textField0
                applicationClassificationCell.certificateId = data.id
            }
            applicationClassificationCell.setDoneButton()
            applicationClassificationCell.backgroundColor = .gray.withAlphaComponent(0.1)
            return applicationClassificationCell
        } else if identifier == "MoneyCell" {
            let moneyCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MoneyCell
            if indexPath.row < certificateDataModel.count {
                let data = certificateDataModel[indexPath.row]
                // 各フィールドにデータを設定
                let displayValue = data.textField01 == 0 ? "" : String(data.textField01)
                moneyCell.textField01.text = displayValue
                moneyCell.certificateId = data.id
            }
            moneyCell.setDoneButton()
            return moneyCell
        } else if identifier == "HierarchyClassificationCell" {
            let hierarchyClassificationCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! HierarchyClassificationCell
            if indexPath.row < certificateDataModel.count {
                let data = certificateDataModel[indexPath.row]
                // 各フィールドにデータを設定
                hierarchyClassificationCell.textField02.text = data.textField02
                hierarchyClassificationCell.certificateId = data.id
            }
            hierarchyClassificationCell.setDoneButton()
            hierarchyClassificationCell.backgroundColor = .gray.withAlphaComponent(0.1)
            return hierarchyClassificationCell
        } else if identifier == "DeadlineCell" {
            let deadlineCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DeadlineCell
            if indexPath.row < certificateDataModel.count {
                let data = certificateDataModel[indexPath.row]
                // 各フィールドにデータを設定
                deadlineCell.year.text = data.year != 0 ? String(data.year) : ""
                deadlineCell.month.text = data.month != 0 ? String(data.month) : ""
                deadlineCell.day.text = data.day != 0 ? String(data.day) : ""
                deadlineCell.year2.text = data.year2 != 0 ? String(data.year2) : ""
                deadlineCell.month2.text = data.month2 != 0 ? String(data.month2) : ""
                deadlineCell.day2.text = data.day2 != 0 ? String(data.day2) : ""
                deadlineCell.certificateId = data.id
            }
            deadlineCell.setDoneButton()
            return deadlineCell
        } else if identifier == "PeriodCell" {
            let periodCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PeriodCell
            let periodCellIndex = indexPath.row // ここでインデックスを取得
            
            if periodCellIndex < certificateDataModel.count {
                let data = certificateDataModel[periodCellIndex]
                // 各フィールドにデータを設定
                periodCell.textField1.text = data.textField1 != 0 ? String(data.textField1) : ""
                periodCell.textField2.text = data.textField2 != 0 ? String(data.textField2) : ""
                periodCell.textField3.text = data.textField3 != 0 ? String(data.textField3) : ""
                periodCell.textField4.text = data.textField4 != 0 ? String(data.textField4) : ""
                periodCell.textField5.text = data.textField5 != 0 ? String(data.textField5) : ""
                periodCell.certificateId = data.id
            }
            periodCell.loadPickerSelection()
            periodCell.setDoneButton()
            
            periodCell.cellIndex = indexPath.row
            return periodCell
//        } else if identifier == "PlusButtonCell" {
//            let plusButtonCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PlusButtonCell
//            plusButtonCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude) // 下辺の線を消す
//            plusButtonCell.delegate = self
//            return plusButtonCell
        } else {
            return UITableViewCell()
        }
    }
    // 行の高さを設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let identifier = tableViewCell[indexPath.row]
        switch identifier {
        case "ApplicationClassificationCell":
            return 70
        case "MoneyCell":
            return 70
        case "HierarchyClassificationCell":
            return 70
        case "DeadlineCell":
            return 155
        case "PeriodCell":
            return 155
//        case "PlusButtonCell":
//            return 40
        default:
            return 70
        }
    }
    // 削除の設定
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        // セルが２つしかない時は削除を無効
//        let periodCellsCount = tableViewCell.filter { $0 == "PeriodCell" }.count
//        if tableViewCell[indexPath.row] == "PeriodCell" && periodCellsCount > 2 {
//            return .delete
//        }
//        return .none
//    }
    // 編集操作
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            guard indexPath.row < certificateDataModel.count && indexPath.row < tableViewCell.count else { return }
//            
//            let realm = try! Realm()
//            let dataToDelete = certificateDataModel[indexPath.row]
//            
//            try! realm.write {
//                realm.delete(dataToDelete)
//            }
//            // TableViewのデータソースから削除
//            tableViewCell.remove(at: indexPath.row)
//            // CertificateDataModelから削除する
//            certificateDataModel.remove(at: indexPath.row)
//            // TableViewからセルを削除
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            tableView.reloadData()
//        }
//    }
    
//    func didTapPlusButton(in cell: PlusButtonCell) {
//        let realm = try! Realm()
//        let newCertificate = CertificateDataModel()
//        
//        try! realm.write {
//            realm.add(newCertificate)
//        }
//        
//        certificateIds.append(newCertificate.id)
//        tableViewCell.insert("PeriodCell", at: tableViewCell.count - 1) // PlusButtonCell の前に追加
//        
//        didSaveCertificate(newCertificate)
//        
//        tableView.reloadData()
//        
//        saveData()
//    }
    
    private func saveData() {
        let realm = try! Realm()
        try! realm.write {
            var periodCellIndex = 0
            // すべてのセルからデータを取得
            for i in 0..<tableViewCell.count {
                let indexPath = IndexPath(row: i, section: 0)
                var certificate: CertificateDataModel
                
                if let cell = tableView.cellForRow(at: indexPath) as? ApplicationClassificationCell {
                    let certificate = CertificateDataModel()
                    certificate.textField0 = cell.textField0.text ?? ""
                    realm.add(certificate, update: .modified)
                } else if let cell = tableView.cellForRow(at: indexPath) as? MoneyCell {
                    let certificate = CertificateDataModel()
                    certificate.textField01 = Int(cell.textField01.text ?? "") ?? 0
                    realm.add(certificate, update: .modified)
                } else if let cell = tableView.cellForRow(at: indexPath) as? HierarchyClassificationCell {
                    let certificate = CertificateDataModel()
                    certificate.textField02 = cell.textField02.text ?? ""
                    realm.add(certificate, update: .modified)
                } else if let cell = tableView.cellForRow(at: indexPath) as? DeadlineCell {
                    let certificate = CertificateDataModel()
                    certificate.year = Int(cell.year.text ?? "") ?? 0
                    certificate.month = Int(cell.month.text ?? "") ?? 0
                    certificate.day = Int(cell.day.text ?? "") ?? 0
                    certificate.year2 = Int(cell.year2.text ?? "") ?? 0
                    certificate.month2 = Int(cell.month2.text ?? "") ?? 0
                    certificate.day2 = Int(cell.day2.text ?? "") ?? 0
                    realm.add(certificate, update: .modified)
                } else if tableViewCell[i] == "PeriodCell" {
                    if periodCellIndex < certificateDataModel.count {
                        certificate = certificateDataModel[periodCellIndex]
                    } else {
                        certificate = CertificateDataModel()
                        certificateDataModel.append(certificate)
                    }
                    if let cell = tableView.cellForRow(at: indexPath) as? PeriodCell {
                        certificate.textField1 = Int(cell.textField1.text ?? "") ?? 0
                        certificate.textField2 = Int(cell.textField2.text ?? "") ?? 0
                        certificate.textField3 = Int(cell.textField3.text ?? "") ?? 0
                        certificate.textField4 = Int(cell.textField4.text ?? "") ?? 0
                        certificate.textField5 = Int(cell.textField5.text ?? "") ?? 0
                    }
                    periodCellIndex += 1
                    realm.add(certificate, update: .modified)
                }
            }
        }
    }
    
    func didSaveCertificate(_ certificate: CertificateDataModel) {
        // certificateIds に id が存在するか確認
        if let index = certificateIds.firstIndex(of: certificate.id) {
            if index < certificateDataModel.count {
                certificateDataModel[index] = certificate
            }
        } else {
            certificateDataModel.append(certificate)
            certificateIds.append(certificate.id)
            tableViewCell.insert("PeriodCell", at: tableViewCell.count - 1) // PlusButtonCell の前に追加
        }
        tableView.reloadData()
    }
}
