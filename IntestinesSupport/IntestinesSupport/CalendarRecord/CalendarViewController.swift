//
//  CalendarViewController.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/07/02.
//

import Foundation
import FSCalendar
import SwiftUI
import RealmSwift

struct SampleIndex {
    var medicineRecordIndex: Int
    var tableViewIndex: Int
}

class CalendarViewController: UIViewController {
    
    private var tableViewCell: [String] = ["CalendarDateCell", "PhysicalConditionCell", "FecesConditionCell", "FecesDetailCell", "AdditionButtonCell", "MedicineEmptyStateCell", "MemoCell"]
    
    var selectedDate: Date?
    private var calendarDataModel: [CalendarDataModel] = []
    private var medicineDataModel: [MedicineDataModel] = []
    private var medicineRecordDataModel: [MedicineRecordDataModel] = []
    private var fecesDetailDataModel: [FecesDetailDataModel] = []
    weak var delegate: CalendarViewControllerDelegate?
    private var medicineRecordIndex = 0
    private var medicineRecordIndices: [Int] = []
    private var indexes: [SampleIndex] = []
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        calendar.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(UINib(nibName: "CalendarDateCell", bundle: nil), forCellReuseIdentifier: "CalendarDateCell")
        tableView.register(UINib(nibName: "PhysicalConditionCell", bundle: nil), forCellReuseIdentifier: "PhysicalConditionCell")
        tableView.register(UINib(nibName: "FecesConditionCell", bundle: nil), forCellReuseIdentifier: "FecesConditionCell")
        tableView.register(UINib(nibName: "FecesDetailCell", bundle: nil), forCellReuseIdentifier: "FecesDetailCell")
        tableView.register(UINib(nibName: "AdditionButtonCell", bundle: nil), forCellReuseIdentifier: "AdditionButtonCell")
        tableView.register(UINib(nibName: "MedicineEmptyStateCell", bundle: nil), forCellReuseIdentifier: "MedicineEmptyStateCell")
        tableView.register(UINib(nibName: "MedicineRecordDetailCell", bundle: nil), forCellReuseIdentifier: "MedicineRecordDetailCell")
        tableView.register(UINib(nibName: "MemoCell", bundle: nil), forCellReuseIdentifier: "MemoCell")
        
        tableView.separatorColor = UIColor.black
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        loadMedicinesData()
        loadCalendars()
        configureCalendar()
        setupCalendarScope()
        indexes.removeAll()
        tableView.reloadData()
        }
        // UserDefaults から色を読み込む
        private func loadColorFromUserDefaults() -> UIColor? {
            if let colorData = UserDefaults.standard.data(forKey: "savedColor"),
               let color = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
                return color
            }
            return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        loadCalendars()
        loadMedicinesData()
        calendar.reloadData()
    }
    
    private func setupCalendarScope() {
        // 画面を閉じた時の表示を再度表示
        let defaults = UserDefaults.standard
        if let savedScope = defaults.string(forKey: "calendarScope") {
            if savedScope == "month" {
                calendar.setScope(.month, animated: false)
                changeButton.setTitle("週表示", for: .normal)
//                calendar.firstWeekday = 2
            } else {
                calendar.setScope(.week, animated: false)
                changeButton.setTitle("月表示", for: .normal)
//                calendar.firstWeekday = 2
            }
        } else {
            // デフォルトの表示形式を月表示に設定
            calendar.setScope(.month, animated: false)
            changeButton.setTitle("週表示", for: .normal)
        }
    }
//    func weekStart() {
//        calendar.firstWeekday = 2
//
//    }
    private func loadCalendars() {
        let realm = try! Realm()
        let calendars = realm.objects(CalendarDataModel.self)
        calendarDataModel = Array(calendars)
    }
    
    private func configureCalendar() {
        // ヘッダーの日付フォーマットを変更
        calendar.appearance.headerDateFormat = "yyyy年MM月"
        // 曜日と今日の色を指定
        calendar.appearance.todayColor = UIColor.orange
        calendar.appearance.headerTitleColor = UIColor.orange
        
        calendar.appearance.weekdayTextColor = .black
        // 曜日表示内容を変更
        calendar.calendarWeekdayView.weekdayLabels[0].text = "日"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "月"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "火"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "水"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "木"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "金"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "土"
        // 土日の色を変更
        calendar.calendarWeekdayView.weekdayLabels[0].textColor = .red
        calendar.calendarWeekdayView.weekdayLabels[6].textColor = .blue
        
        // 現在のUTC時間を取得
        let now = Date()
        // カレンダーを取得
        let calendarCurrent = Calendar.current
        // おそらく、FSCalendarの日付が世界標準時間をもとに計算されているので、時差を考慮して当日を基準にマイナス1日する
        guard let previousDay = calendarCurrent.date(byAdding: .day, value: -1, to: now) else { return }
        // 現在の年、月、日を取得
        let components = calendarCurrent.dateComponents([.year, .month, .day], from: previousDay)
        // UTCの15:00を設定
        var utcComponents = DateComponents()
        utcComponents.year = components.year
        utcComponents.month = components.month
        utcComponents.day = components.day
        utcComponents.hour = 15
        utcComponents.timeZone = TimeZone(abbreviation: "UTC")
        // UTCの15:00の日付を取得
        guard let utcDate = calendarCurrent.date(from: utcComponents) else { return }
        // 現在の日付を初期値としてセットする
        selectedDate = utcDate
        // カレンダーの日付を選択される
        calendar.select(utcDate)
    }
    // calendarの表示形式変更
    @IBAction func changeButtonAction(_ sender: Any) {
        if calendar.scope == .month {
            calendar.setScope(.week, animated: true)
            changeButton.setTitle("月表示", for: .normal)
            saveCalendarScope(scope: .week)
            calendar.reloadData()
        } else if calendar.scope == .week {
            calendar.setScope(.month, animated: true)
            changeButton.setTitle("週表示", for: .normal)
            saveCalendarScope(scope: .month)
            calendar.reloadData()
        }
    }
    
    private func saveCalendarScope(scope: FSCalendarScope) {
        let defaults = UserDefaults.standard
        defaults.set(scope == .month ? "month" : "week", forKey: "calendarScope")
    }
    
    func didTapRecordButton(in cell: FecesDetailCell) {
        performSegue(withIdentifier: "FecesRecord", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segueのIDを確認して特定のsegueのときのみ動作させる
        if segue.identifier == "FecesRecord" {
            // 2. 遷移先のViewControllerを取得
            let next = segue.destination as? FecesRecordViewController
            // 3. １で用意した遷移先の変数に値を渡す
            next?.selectedDate = selectedDate
        } else if segue.identifier == "MedicineAddition" {
            if let nextVC = segue.destination as? MedicineAdditionViewController {
                nextVC.delegate = self
                nextVC.selectDate = selectedDate
            }
        }
    }
    
    func didTapAdditionButton(in cell: AdditionButtonCell) {
        performSegue(withIdentifier: "MedicineAddition", sender: self)
    }
    
    func didTapPlusButton(in cell: FecesDetailCell) {
        // 例: 新しいレコードを作成
        let newRecord = CalendarDataModel()
        newRecord.date = selectedDate ?? Date() // 選択された日付がなければ現在の日付を使用
        
        // Realmに保存
        let realm = try! Realm()
        try! realm.write {
            realm.add(newRecord)
        }
        
        // データのリフレッシュ
        loadCalendars()
        tableView.reloadData()
        
        // カレンダーに新しいレコードを反映
        calendar.reloadData()
    }
    private func refreshData() {
        loadCalendars()
        tableView.reloadData()
    }
    private func reloadData() {
        medicineRecordIndex = 0
        tableView.reloadData()
    }
}

// MARK: tableView関連
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource  {
    func loadMedicinesData() {
        let realm = try! Realm()
        let medicineRecords = realm.objects(MedicineRecordDataModel.self)
        medicineRecordDataModel = Array(medicineRecords).filter({ $0.date == selectedDate })
        let medicineRecordCount = medicineRecordDataModel.count
        updateTableViewCells(with: medicineRecordCount)
        reloadData()
    }
    
    func updateTableViewCells(with medicineRecordCount: Int) {
        // MedicineEmptyStateCell を削除
        if let emptyStateIndex = tableViewCell.firstIndex(of: "MedicineEmptyStateCell") {
            tableViewCell.remove(at: emptyStateIndex)
        }
        // 現在の MedicineRecordDetailCell の数を取得
        let currentDetailCellsCount = tableViewCell.filter { $0 == "MedicineRecordDetailCell" }.count
        
        if medicineRecordCount > currentDetailCellsCount {
            // 不足分のセルを追加
            let cellsToAdd = medicineRecordCount - currentDetailCellsCount
            let insertIndex = min(5, tableViewCell.count) // 挿入位置の決定
            tableViewCell.insert(contentsOf: Array(repeating: "MedicineRecordDetailCell", count: cellsToAdd), at: insertIndex)
        } else if medicineRecordCount < currentDetailCellsCount {
            // 余分なセルを削除
            let cellsToRemove = currentDetailCellsCount - medicineRecordCount
            for _ in 0..<cellsToRemove {
                if let lastIndex = tableViewCell.lastIndex(of: "MedicineRecordDetailCell") {
                    tableViewCell.remove(at: lastIndex)
                }
            }
        }
        if medicineRecordCount == 0 {
            removeMedicineRecordDetailCell()
        }
        findMedicineRecordDetailIndices()
        reloadData()
    }
    
    func findMedicineRecordDetailIndices() {
        // tableViewCell配列をループして"MedicineRecordDetailCell"のインデックスを取得
        medicineRecordIndices = tableViewCell.enumerated().compactMap { index, cell in
            return cell == "MedicineRecordDetailCell" ? index : nil
        }
    }
    
    private func removeMedicineRecordDetailCell() {
        // 削除対象のインデックスを収集
        let indicesToRemove = getIndicesToRemove(for: "MedicineRecordDetailCell")
        for index in indicesToRemove.reversed() {
            removeCell(at: index)
        }
        if !tableViewCell.contains("MedicineEmptyStateCell") {
            let insertIndex = min(5, tableViewCell.count)
            tableViewCell.insert("MedicineEmptyStateCell", at: insertIndex)
        }
    }
    
    private func getIndicesToRemove(for cellType: String) -> [Int] {
        return tableViewCell.enumerated()
            .filter { $0.element == cellType }
            .map { $0.offset }
    }
    
    private func removeCell(at index: Int) {
        if index < tableViewCell.count {
            tableViewCell.remove(at: index)
        }
        if index < medicineRecordDataModel.count {
            medicineRecordDataModel.remove(at: index)
        }
    }
    // 行数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewCell.count
    }
    // 各行の内容を設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let selectedDate = selectedDate else {
            return tableView.dequeueReusableCell(withIdentifier: "MedicineEmptyStateCell", for: indexPath) as! MedicineEmptyStateCell
        }
        
        let identifier = tableViewCell[indexPath.row]
        
        
        let filteredCalendarDataModel = calendarDataModel.filter { $0.date == selectedDate }.first
        
        if identifier == "CalendarDateCell" {
            let calendarCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CalendarDateCell
            calendarCell.configure(with: selectedDate)
            return calendarCell
        } else if identifier == "PhysicalConditionCell" {
            let physicalConditionCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PhysicalConditionCell
            physicalConditionCell.delegate = self
            // CalendarDataModelがnilの場合は早期リターンする
            guard let model = filteredCalendarDataModel else {
                // nilの場合は日付だけ必要なのでそれをセットする
                physicalConditionCell.configure(selectedDate: selectedDate)
                return physicalConditionCell
            }
            physicalConditionCell.configure(selectedIndex: model.selectedPhysicalConditionIndex, model: model , selectedDate: selectedDate)
            return physicalConditionCell
        } else if identifier == "FecesConditionCell" {
            let fecesConditionCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! FecesConditionCell
            fecesConditionCell.delegate = self
            // CalendarDataModelがnilの場合は早期リターンする
            guard let model = filteredCalendarDataModel else {
                // nilの場合は日付だけ必要なのでそれをセットする
                fecesConditionCell.configure(selectedDate: selectedDate)
                return fecesConditionCell
            }
            fecesConditionCell.configure(selectedIndex: model.selectedFecesConditionIndex, model: model , selectedDate: selectedDate)
            return fecesConditionCell
        } else if identifier == "FecesDetailCell" {
            let fecesDetailCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! FecesDetailCell
            fecesDetailCell.delegate = self
            // CalendarDataModelがnilの場合は早期リターンする
            guard let model = filteredCalendarDataModel else {
                // nilの場合は日付だけ必要なのでそれをセットする
                fecesDetailCell.configure(selectedDate: selectedDate)
                return fecesDetailCell
            }
            return fecesDetailCell
        } else if identifier == "AdditionButtonCell" {
            let additionButtonCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! AdditionButtonCell
            additionButtonCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            additionButtonCell.delegate = self
            return additionButtonCell
        } else if identifier == "MedicineEmptyStateCell" {
            let medicineEmptyStateCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MedicineEmptyStateCell
            medicineEmptyStateCell.messageLabel.text = "服用はありません"
            medicineEmptyStateCell.messageLabel.textColor = .gray // テキストの色を薄く設定
            medicineEmptyStateCell.messageLabel.textAlignment = .center
            medicineEmptyStateCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            return medicineEmptyStateCell
        } else if identifier == "MedicineRecordDetailCell" {
            let medicineRecordDetailCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MedicineRecordDetailCell
            medicineRecordDetailCell.delegate2 = self
            
            if medicineRecordIndex < medicineRecordDataModel.count {
                let medicine = medicineRecordDataModel[medicineRecordIndex]
                
                medicineRecordDetailCell.medicineName.text = medicine.medicineName
                medicineRecordDetailCell.unit.text = medicine.unit
                medicineRecordDetailCell.label.text = "\(medicine.label)"
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "ja_JP")
                dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
                dateFormatter.dateFormat = "HH:mm"
                
                let timePickerDate = medicine.timePicker
                medicineRecordDetailCell.timePicker.setDate(timePickerDate, animated: false)
                
                let formattedTime = dateFormatter.string(from: timePickerDate)
                
                if MyMedicines.sharedPickerData2.isEmpty {
                    medicineRecordDetailCell.unit.text = "" // ピッカーが空ならラベルを空白に
                }
                medicineRecordDetailCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                medicineRecordIndex += 1
                
                // ここで sampleIndex を作成し、indexes に追加
                let sampleIndex = SampleIndex(medicineRecordIndex: medicineRecordIndex, tableViewIndex: indexPath.row)
                indexes.append(sampleIndex)
                // configure メソッドでセルにデータを設定
                medicineRecordDetailCell.configure(medicineName: medicine.medicineName, timePicker: timePickerDate, label: medicine.label, unit: medicine.unit)
                // 色の設定
                medicineRecordDetailCell.setupCell(borderColor: UIColor.systemTeal)
            }
            return medicineRecordDetailCell
        } else if identifier == "MemoCell" {
            let memoCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MemoCell
            memoCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude) // 線を消す
            memoCell.delegate = self
            guard let model = filteredCalendarDataModel else {
                // nilの場合は日付だけ必要なのでそれをセットする
                memoCell.configure(selectedIndex: "", selectedDate: selectedDate)
                return memoCell
            }
            memoCell.configure(selectedIndex: model.memo, model: model , selectedDate: selectedDate)
            memoCell.setDoneButton()
            return memoCell
        } else {
            return UITableViewCell()
        }
    }
    // 全てのCellの選択を不可にする
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    // 行の高さを設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 3行目の高さを固定
        if indexPath.row == 3 {
            return 80
        }
        let startingRow = 5
        let lastRow = tableView.numberOfRows(inSection: indexPath.section) - 1 // 最後のインデックス
        if indexPath.row == lastRow {
            return 200
        }
        
        if indexPath.row >= startingRow && indexPath.row <= lastRow {
            return 50
        } else {
            return UITableView.automaticDimension // それ以外のセルは自動調整
        }
    }
    // 記録のある日付の下に点を表示
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateList = calendarDataModel.map({ $0.date.zeroclock })
        // 比較対象のDate型の年月日が一致していた場合にtrueとなる
        let isEqualDate = dateList.contains(date.zeroclock)
        return isEqualDate ? 1 : 0
    }
    // 点の色を設定
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let dateList = calendarDataModel.map { $0.date.zeroclock }
        let isEqualDate = dateList.contains(date.zeroclock)
        // 記録がある日付に特定の色を設定
        if isEqualDate {
            return [UIColor.red] // 点の色を赤に設定
        }
        return nil
    }
    // MedicineRecordDetailCellだけ削除
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let tableViewCell = tableViewCell[indexPath.row]
        return tableViewCell == "MedicineRecordDetailCell"
    }
    // 削除の設定
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let tableViewCell = tableViewCell[indexPath.row]
        if tableViewCell == "MedicineRecordDetailCell" {
            return .delete
        }
        return .none
    }
    // 行の編集操作
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 対象のtableViewCellのStringを削除
        tableViewCell.remove(at: indexPath.row)
        
        // medicineRecordIndicesから対象のIndexを取得する
        if let index = medicineRecordIndices.firstIndex(where: { $0 == indexPath.row }) {
            let medicineRecord = medicineRecordDataModel[index]
            updateMedicineDataModel(medicineRecord, isDelete: true)
            let realm = try! Realm()
            if index < medicineRecordDataModel.count {
                try! realm.write {
                    realm.delete(medicineRecord)
                }
            }
            medicineRecordDataModel.remove(at: index)
        }
        // 最新のmedicineRecordDataModelからupdateTableViewCellsを呼んでtableViewCellを作り直す
        updateTableViewCells(with: medicineRecordDataModel.count)
        reloadData()
    }
    
    func saveSelectedDate(date: Date) {
        let realm = try! Realm()
        
        if let existingRecord = realm.objects(MedicineRecordDataModel.self).first {
            // 既存のレコードがある場合は、日付を更新する
            try! realm.write {
                existingRecord.date = date
                realm.add(existingRecord, update: .modified)
            }
        } else {
            // 既存のレコードがない場合は、新しいレコードを作成する
            let newRecord = MedicineRecordDataModel()
            newRecord.date = date
            
            try! realm.write {
                realm.add(newRecord)
            }
        }
    }
}

extension CalendarViewController: FecesDetailCellDelegate, AdditionButtonCellDelegate, MedicineAdditionViewControllerDelegate, MedicineRecordDetailCellDelegate {
    
    func didChangeData(for cell: MedicineRecordDetailCell, newTime: Date) {
        // tableViewからセルのindexPathを取得
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let sampleIndex = indexes.first { $0.tableViewIndex == indexPath.row }
        // インデックスの範囲チェック
        if let sampleIndex = sampleIndex, sampleIndex.medicineRecordIndex - 1 < medicineRecordDataModel.count {
            let medicine = medicineRecordDataModel[sampleIndex.medicineRecordIndex - 1]
            let realm = try! Realm()
            
            try! realm.write {
                // 時間データを更新
                medicine.timePicker = newTime
                realm.add(medicine, update: .modified)
            }
            // セルの表示を更新（セルの位置が変わらないように）
            if let updatedCell = tableView.cellForRow(at: indexPath) as? MedicineRecordDetailCell {
                updatedCell.timePicker.setDate(newTime, animated: true)
            }
        }
    }
    
    func didSaveMedicineRecord(_ record: MedicineRecordDataModel) {
        // 既存データと重複しないようにチェック
        if !medicineRecordDataModel.contains(where: { $0.medicineName == record.medicineName && $0.timePicker == record.timePicker }) {
            medicineRecordDataModel.append(record)
            
            let newIndex = medicineRecordDataModel.count - 1
            let medicineRecordCount = medicineRecordDataModel.count
            updateMedicineDataModel(record, isDelete: false)
            
            updateMedicineDataModel(record, isDelete: false)
            
            updateTableViewCells(with: medicineRecordCount)
            
            reloadData()
        }
    }
    
    func updateMedicineDataModel(_ record: MedicineRecordDataModel, isDelete: Bool) {
        let realm = try! Realm()
        // MedicineDataModelの対象レコードを取得
        if let targetEmployee = realm.objects(MedicineDataModel.self).filter("id == %@", record.medicineModelId).first {
            // stockが0の場合は計算をスキップ
            if targetEmployee.stock == 0 {
                return
            }
            
            do {
                try realm.write {
                    // labelValueが数値かどうかを確認
                    if let labelValue = Double(record.label) {
                        // stock の更新処理
                        if isDelete {
                            targetEmployee.stock += labelValue
                        } else {
                            targetEmployee.stock -= labelValue
                        }
                    }
                }
            } catch {
                print("該当するレコードが見つかりません: \(record.medicineModelId)")
            }
        }
    }
    
    func updateDatePicker(with date: Date) {
        // 使用しない
    }
    
    func didTapPlusButton(indexes: [Int]) {
        guard let selectedDate else { return }
        
        let realm = try! Realm()
        let model = realm.objects(FecesDetailDataModel.self)
        
        let currentTime = Date()
        
        let newData = FecesDetailDataModel(
            date: selectedDate,
            fecesDetailTypeRowValues: indexes,
            time: currentTime
        )
        
        try! realm.write {
            realm.add(newData)
        }
    }
}

// MARK: CalendarViewControllerDelegate関連 / RealmDataの保存を行う
extension CalendarViewController: CalendarViewControllerDelegate {
    func didUpdateStockValue(_ stockValue: Double) {
        // 使用しない
    }
    
    func saveCalendarData(_ newData: CalendarDataModel) {
        let realm = try! Realm()
        // Realmのデータの中に同じidが存在するならそれをもとに更新する
        if let object = realm.objects(CalendarDataModel.self).filter("id == %@", newData.id).first {
            try! realm.write {
                object.date = newData.date
                object.selectedPhysicalConditionIndex = newData.selectedPhysicalConditionIndex
                object.selectedFecesConditionIndex = newData.selectedFecesConditionIndex
                //                object.medicineRecord = newData.medicineRecord
                object.memo = newData.memo
            }
        } else {
            // idが一致しない場合は新規で保存する
            try! realm.write {
                realm.add(newData)
            }
        }
        // Realmの保存が完了した後TableViewをリロードする
        refreshData()
    }
}

// MARK: FSCalendarDelegate関連
extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    // 日付が選択されたときに呼び出されるメソッド
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        let realm = try! Realm()
        let medicineRecords = realm.objects(MedicineRecordDataModel.self)
        medicineRecordDataModel = Array(medicineRecords).filter({
            return $0.date == selectedDate
        })
        let medicineRecordCount = medicineRecordDataModel.count
        updateTableViewCells(with: medicineRecordCount)
        reloadData() // 選択された日付に関連するデータを表示するためにテーブルビューをリロード
    }
    // カレンダーの日付のタイトルの色をカスタマイズするメソッド
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let weekday = Calendar.current.component(.weekday, from: date)
        
        // 土曜日の場合、タイトルの色を青にする
        if weekday == 7 {
            return .blue
            // 日曜日の場合、タイトルの色を赤にする
        } else if weekday == 1 {
            return .red
        }
        return nil // その他の日はデフォルトの色を使用
    }
    
    // カレンダーの高さが変更されるときに呼び出されるメソッド
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        // カレンダーの高さ制約を更新
        calendarHeight.constant = bounds.height
        // レイアウトの更新を即時反映
        self.view.layoutIfNeeded()
    }
}

