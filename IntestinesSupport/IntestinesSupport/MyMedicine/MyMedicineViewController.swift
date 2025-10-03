//
//  MyMedicine.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/07/03.
//

import SwiftUI
import UIKit
import RealmSwift

class MyMedicineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MedicineViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var medicineDataModel: [MedicineDataModel] = []
    var selectedIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.isHidden = true
        
        tableView.register(UINib(nibName: "MedicineTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        loadMedicines()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMedicines()
    }
    
    func loadMedicines() {
        let realm = try! Realm()
        let MyMedicines = realm.objects(MedicineDataModel.self)
        medicineDataModel.removeAll()
        medicineDataModel = Array(MyMedicines)
        tableView.reloadData()
    }
    // 行数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medicineDataModel.filter { !$0.isInvalidated }.count
    }
    // 各行の内容を設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! MedicineTableViewCell
        let filteredData = medicineDataModel.filter { !$0.isInvalidated }
        
        guard indexPath.row < filteredData.count else {
            return UITableViewCell()
        }
        let medicine = filteredData[indexPath.row]
        // セルの設定
        cell.medicineNameLabel.text = medicine.medicineName
        if medicine.stock == Double(Int(medicine.stock)) {
            cell.stockNumberLabel.text = "\(Int(medicine.stock))" // ０の場合整数として表示
        } else {
            cell.stockNumberLabel.text = "\(medicine.stock)" // 小数としてそのまま表示
        }
        cell.stockUnitLabel.text = medicine.label
        
        if MyMedicines.sharedPickerData2.isEmpty {
            cell.stockUnitLabel.text = "" // ピッカーが空ならラベルを空白に
        }
        
        cell.selectionStyle = .none // セル選択時の色の変化を無効化
        return cell
    }
    // 行の編集操作
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let realm = try! Realm()
            
            // 削除対象のオブジェクトを取得
            let medicineToDelete = medicineDataModel[indexPath.row]
            
            // メモリ上のデータを削除
            medicineDataModel.remove(at: indexPath.row)
            
            // Realmからも削除
            try! realm.write {
                realm.delete(medicineToDelete)
            }
            // テーブルビューを更新
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    // 選択された時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択されたセルのデータを取得
        let selectedMedicine = medicineDataModel[indexPath.row]
        selectedIndex = indexPath // 選択したインデックスを保存
        // ストーリーボードからビューコントローラーを取得
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let infoVC = storyboard.instantiateViewController(withIdentifier: "MyMedicineInformation") as? MyMedicineInformation else {
            return
        }
        infoVC.isEditingExistingMedicine = true  // 編集中であることを示すフラグを設定
        infoVC.delegate = self
        infoVC.selectedMedicine = selectedMedicine
        let navigationController = UINavigationController(rootViewController: infoVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    // 行が編集可能かどうか
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    // デリゲートメソッド
    func didSaveMedicine(_ medicine: MedicineDataModel) {
        let realm = try! Realm()
        
        // 選択されたセルを削除
        if let existingIndex = selectedIndex {
            // インデックスが範囲内か確認
            if existingIndex.row < medicineDataModel.count {
                let oldMedicine = medicineDataModel[existingIndex.row]
                medicineDataModel.remove(at: existingIndex.row)
                tableView.deleteRows(at: [existingIndex], with: .automatic)
                
                try! realm.write {
                    realm.delete(oldMedicine)
                }
            }
        }
        // 新しいデータを追加
        medicineDataModel.append(medicine)
        
        try! realm.write {
            realm.add(medicine, update: .modified)
        }
        tableView.reloadData()
    }
    
    func didDeleteMedicine(_ medicine: MedicineDataModel) {
        // 削除したいデータをデータモデルから削除
        if let index = medicineDataModel.firstIndex(of: medicine) {
            medicineDataModel.remove(at: index)
        }
        tableView.reloadData()
        
        if medicineDataModel.count > 0 {
            // すべてのインデックスを表示
            for index in 0..<medicineDataModel.count {
            }
        }
        selectedIndex = nil
    }
    // 遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "next" {
            if let next = segue.destination as? MyMedicineInformation {
                next.delegate = self
            }
        }
    }
}
