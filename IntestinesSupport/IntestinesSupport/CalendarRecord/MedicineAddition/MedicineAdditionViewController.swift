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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MedicineAdditionTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        tableView.allowsMultipleSelection = true
        loadMedicines()
        selectedCellButton()
        buttonSetup()
    }
    func loadMedicines() {
        let realm = try! Realm()
        medicineDataModel = Array(realm.objects(MedicineDataModel.self))
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medicineDataModel.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! MedicineAdditionTableViewCell
        let medicine = medicineDataModel[indexPath.row]
        cell.medicineName.text = medicine.medicineName
        cell.unitLabel.text = medicine.label
        cell.textField.text = "\(medicine.doseNumber)"
        
        
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        
        cell.selectionStyle = .none // セルを選択したときに色が変わらないようにする
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            // 新しく選択された場合はチェックマークを付ける
            cell.accessoryType = .checkmark
            selectedIndexPaths.append(indexPath)
            selectedCellButton()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            // 選択が解除された場合はチェックマークを外す
            cell.accessoryType = .none
            selectedIndexPaths.removeAll { $0 == indexPath }
            selectedCellButton()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0 // セルの高さ
    }
    @IBAction func medicineAdditionButton(_ sender: UIButton) {
        let recordData = MedicineRecordDataModel()
        let realm = try! Realm()
        
        // 選択されたインデックスパスからセルを取得
        for indexPath in selectedIndexPaths {
            if let cell = tableView.cellForRow(at: indexPath) as? MedicineAdditionTableViewCell {
                let recordData = MedicineRecordDataModel()
                
                // セルの情報をデータモデルに保存
                recordData.medicineName = cell.medicineName.text ?? ""
                recordData.unit = cell.unitLabel.text ?? ""
                if let doseNumber = Int(cell.textField.text ?? "") {
                    recordData.textField = doseNumber
                }
                recordData.timePicker = cell.timePicker.date
                
                // Realm に変更を保存
                try! realm.write {
                    realm.add(recordData, update: .modified)
                }
                
                let savedData = realm.objects(MedicineRecordDataModel.self).filter("medicineName = %@ AND timePicker = %@", recordData.medicineName, recordData.timePicker)
                for data in savedData {
                    print("😡Saved MedicineRecordDataModel: \(data) 保存完了")
                }
                
                if let calendarVC = self.storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController {
                    calendarVC.selectedDate = cell.timePicker.date
                    self.navigationController?.pushViewController(calendarVC, animated: true)
                }
            }
        }
        delegate?.didSaveMedicineRecord(recordData)
        dismiss(animated: true, completion: nil) // モーダル画面を閉じる
    }
    private func selectedCellButton() {
        medicineAdditionButton.isEnabled = !selectedIndexPaths.isEmpty
    }
    private func buttonSetup() {
        medicineAdditionButton.backgroundColor = UIColor.clear // 背景色
        medicineAdditionButton.layer.borderWidth = 2.0 // 枠線の幅
        medicineAdditionButton.layer.borderColor = UIColor.blue.cgColor // 枠線の色
        medicineAdditionButton.layer.cornerRadius = 10.0 // 角丸のサイズ
        medicineAdditionButton.tintColor = UIColor.blue
    }
}

extension MedicineAdditionViewController: AdditionButtonCellDelegate {
    func didTapAdditionButton(in cell: AdditionButtonCell) {
    }
}
extension MedicineAdditionViewController: MedicineViewControllerDelegate {
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
