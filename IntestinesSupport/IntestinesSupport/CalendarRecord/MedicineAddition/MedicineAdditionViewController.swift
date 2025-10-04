//
//  MedicineAdditionViewController.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/08/27.
//

import Foundation
import UIKit
import RealmSwift

protocol MedicineAdditionViewControllerDelegate: AnyObject {
    func didSaveMedicineRecord(_ record: MedicineRecordDataModel)
}

class MedicineAdditionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var medicineAdditionButton: UIButton!
    
    weak var delegate: MedicineAdditionViewControllerDelegate?
    private var medicineDataModel: [MedicineDataModel] = []
    private var medicineRecordDataModel: [MedicineRecordDataModel] = []
    // 選択されたセルのインデックスパスを保持する配列
    private var selectedIndexPaths: [IndexPath] = []
    var additionButtonCell: AdditionButtonCell?
    var selectDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MedicineRecordEmptyTableViewCell", bundle: nil), forCellReuseIdentifier: "MedicineRecordEmptyTableViewCell")
        tableView.register(UINib(nibName: "MedicineAdditionTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        tableView.allowsMultipleSelection = true
        loadMedicines()
        selectedCellButton()
//        buttonSetup()
    }
    
    func loadMedicines() {
        let realm = try! Realm()
        medicineDataModel = Array(realm.objects(MedicineDataModel.self))
        tableView.reloadData()
    }
    // 行図鵜を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if medicineRecordDataModel.isEmpty {
            return 1
        } else {
            return medicineDataModel.count
        }
    }
    // 各行の内容を設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if medicineDataModel.isEmpty {
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "MedicineRecordEmptyTableViewCell", for: indexPath) as! MedicineRecordEmptyTableViewCell
            emptyCell.medicineRecordEmptyLabel.text = "お薬を追加してください"
            emptyCell.medicineRecordEmptyLabel.textColor = .gray
            emptyCell.medicineRecordEmptyLabel.textAlignment = .center
            emptyCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            emptyCell.selectionStyle = .none
            return emptyCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! MedicineAdditionTableViewCell
            let medicine = medicineDataModel[indexPath.row]
            cell.medicineName.text = medicine.medicineName
            cell.unitLabel.text = medicine.label
            cell.modelId = medicine.id
            
            let doseNumber = medicine.doseNumber
            // 整数の場合は Int として表示
            if let doseInt = Int(exactly: doseNumber) {
                cell.textField.text = "\(doseInt)"
            } else {
                cell.textField.text = "\(doseNumber)"
            }
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            
            cell.selectionStyle = .none // セルを選択したときに色が変わらないようにする
            
            return cell
        }
    }
    // 行が選択された時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            // 新しく選択された場合はチェックマークを付ける
            cell.accessoryType = .checkmark
            selectedIndexPaths.append(indexPath)
            selectedCellButton()
        }
    }
    // 行が選択解除された時の処理
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            // 選択が解除された場合はチェックマークを外す
            cell.accessoryType = .none
            selectedIndexPaths.removeAll { $0 == indexPath }
            selectedCellButton()
        }
    }
    // 行の高さを設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0 // セルの高さ
    }
    
    @IBAction func medicineAdditionButton(_ sender: UIButton) {
        let record = MedicineRecordDataModel()
        var recordsToSave: [MedicineRecordDataModel] = []
        let realm = try! Realm()
        
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        // 現在日時をフォーマットした文字列に変換
        let timeString = dateFormatter.string(from: currentDate)
        
        let formattedDate = dateFormatter.date(from: timeString)!
        
        // 選択されたインデックスパスからセルを取得
        for indexPath in selectedIndexPaths {
            if let cell = tableView.cellForRow(at: indexPath) as? MedicineAdditionTableViewCell {
                let record = MedicineRecordDataModel()
                try! realm.write {
                    // セルの情報をデータモデルに保存
                    record.medicineName = cell.medicineName.text ?? ""
                    record.unit = cell.unitLabel.text ?? ""
                    record.label = cell.textField.text ?? ""
                    record.medicineModelId = cell.modelId
                    
                    if let selectDate {
                        record.date = selectDate
                    }
                    record.timePicker = cell.timePicker.date
                    realm.add(record, update: .modified)
                }
                
                if let calendarVC = self.storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController {
                    calendarVC.selectedDate = cell.timePicker.date
                    self.navigationController?.pushViewController(calendarVC, animated: true)
                }
                recordsToSave.append(record)
            }
        }
        
        for record in recordsToSave {
            delegate?.didSaveMedicineRecord(record)
        }
        dismiss(animated: true, completion: nil) // モーダル画面を閉じる
        
        // カレンダー画面への遷移
        if let calendarVC = self.storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController {
            self.navigationController?.pushViewController(calendarVC, animated: true)
        }
    }
    
    private func selectedCellButton() {
        medicineAdditionButton.isEnabled = !selectedIndexPaths.isEmpty
    }
    
//    private func buttonSetup() {
//        medicineAdditionButton.backgroundColor = UIColor.clear // 背景色
//        medicineAdditionButton.layer.borderWidth = 2.0 // 枠線の幅
//        medicineAdditionButton.layer.borderColor = UIColor.blue.cgColor // 枠線の色
//        medicineAdditionButton.layer.cornerRadius = 10.0 // 角丸のサイズ
//        medicineAdditionButton.tintColor = UIColor.blue
//    }
}

extension MedicineAdditionViewController: AdditionButtonCellDelegate, MedicineViewControllerDelegate {
    func didChangeUnit(to newUnit: String) {
        // 使用しない
    }
    
    func didTapAdditionButton(in cell: AdditionButtonCell) {
        // 使用しない
    }
    
    func didSaveMedicine(_ medicine: MedicineDataModel) {
        medicineDataModel.append(medicine)
        loadMedicines()
        tableView.reloadData()
    }
    
    func didDeleteMedicine(_ medicine: MedicineDataModel) {
        medicineDataModel.append(medicine)
        loadMedicines()
        tableView.reloadData()
    }
}
