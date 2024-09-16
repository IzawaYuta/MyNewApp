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

class CalendarViewController: UIViewController {
    
    private var tableViewCell: [String] = ["CalendarDateCell", "PhysicalConditionCell", "FecesConditionCell", "FecesDetailCell", "AdditionButtonCell", "MedicineEmptyStateCell", "MemoCell"]
    
    var selectedDate: Date?
    private var calendarDataModel: [CalendarDataModel] = []
    private var medicineDataModel: [MedicineDataModel] = []
    private var medicineRecordDataModel: [MedicineRecordDataModel] = []
    weak var delegate: CalendarViewControllerDelegate?
    private var medicineRecordIndex = 0
    private var medicineRecordIndices: [Int] = []
    
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
        //                loadMedicineRecords()
        loadSelectedDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCalendars()
        calendar.reloadData()
    }
    
    private func setupCalendarScope() {
        // 画面を閉じた時の表示を再度表示
        let defaults = UserDefaults.standard
        if let savedScope = defaults.string(forKey: "calendarScope") {
            if savedScope == "month" {
                calendar.setScope(.month, animated: false)
                changeButton.setTitle("週表示", for: .normal)
            } else {
                calendar.setScope(.week, animated: false)
                changeButton.setTitle("月表示", for: .normal)
            }
        } else {
            // デフォルトの表示形式を月表示に設定
            calendar.setScope(.month, animated: false)
            changeButton.setTitle("週表示", for: .normal)
        }
    }
    
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
    
    // FIXME: 遷移するとクラッシュする
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
        //                newRecord.selectedFecesDetailIndex = 0 // 必要に応じて適切な値に設定
        
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
        medicineRecordIndex += 1
        tableView.reloadData()
    }
    func updateTableViewCells(with medicineRecordCount: Int) {
        // 現在のセル数を取得
        let currentCellCount = tableViewCell.count
        
        if medicineRecordCount > 0 {
            let detailCells = Array(repeating: "MedicineRecordDetailCell", count: medicineRecordCount)
            
            // MedicineEmptyStateCell を削除
            if let emptyStateIndex = tableViewCell.firstIndex(of: "MedicineEmptyStateCell") {
                tableViewCell.remove(at: emptyStateIndex)
            }
            let numberOfDetailCells = tableViewCell.filter { $0 == "MedicineRecordDetailCell" }.count
            let cellsToAdd = max(0, medicineRecordCount - numberOfDetailCells)
            let insertIndex = min(5, tableViewCell.count)
            
            if cellsToAdd > 0 {
                tableViewCell.insert(contentsOf: Array(repeating: "MedicineRecordDetailCell", count: cellsToAdd), at: insertIndex)
            }
        } else {
            removeMedicineRecordDetailCell()
        }
        findMedicineRecordDetailIndices()
        
        reloadData()
        //        print("🌕 tableViewCell : \(tableViewCell)")
    }
    func findMedicineRecordDetailIndices() {
        // tableViewCell配列をループして"MedicineRecordDetailCell"のインデックスを取得
        medicineRecordIndices = tableViewCell.enumerated().compactMap { index, cell in
            return cell == "MedicineRecordDetailCell" ? index : nil
        }
        //        print("MedicineRecordDetailCellのインデックス: \(medicineRecordIndices)")
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("\(calendarDataModel)")
        
        return tableViewCell.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 基本的には selectedDateがnilならない(なっている場合はバグが発生している)
        // selectedDateのロジックが成立していない状態でCellの選択をさせ、保存させてしまうと保存データがおかしくなるのでEmptyStateCell自体は個人的にはあっても良いかなと思います
        // 最終的な判断はお任せします
        //        guard let selectedDate else { return EmptyStateCell()}
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
            // fecesDetailCell.configure(selectedIndex: model.selectedFecesDetailIndex, model: model , selectedDate: selectedDate)
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
            medicineRecordDetailCell.delegate = self
            //            guard let model = filteredCalendarDataModel else {
            //                medicineRecordDetailCell.configure(medicineRecord: nil,selectedDate: selectedDate)
            //                return medicineRecordDetailCell
            //            }
            if medicineRecordIndex < medicineRecordDataModel.count {
                let medicine = medicineRecordDataModel[medicineRecordIndex]
                medicineRecordDetailCell.medicineName.text = medicine.medicineName
                medicineRecordDetailCell.unit.text = medicine.unit
                medicineRecordDetailCell.textField.text = "\(medicine.textField)"
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "ja_JP")
                dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
                dateFormatter.dateFormat = "HH:mm"
                
                let timePickerDate = medicine.timePicker
                medicineRecordDetailCell.timePicker.setDate(timePickerDate, animated: false)
                
                let formattedTime = dateFormatter.string(from: timePickerDate)
                medicineRecordDetailCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                medicineRecordIndex += 1
            }
//                        medicineRecordDetailCell.configure(medicineRecord: model.medicineRecord, model: model , selectedDate: selectedDate)
            return medicineRecordDetailCell
        } else if identifier == "MemoCell" {
            let memoCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MemoCell
            memoCell.delegate = self
            guard let model = filteredCalendarDataModel else {
                // nilの場合は日付だけ必要なのでそれをセットする
                memoCell.configure(selectedIndex: "", selectedDate: selectedDate)
                return memoCell
            }
            memoCell.configure(selectedIndex: model.memo, model: model , selectedDate: selectedDate)
            memoCell.setDoneButton()
            memoCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            return memoCell
        } else {
            return UITableViewCell()
        }
    }
    
    /// 全てのCellの選択を不可にする
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return 80 // 3行目の高さを80に設定
        } else {
            return UITableView.automaticDimension
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let tableViewCell = tableViewCell[indexPath.row]
        if tableViewCell == "MedicineRecordDetailCell" {
            return .delete
        }
        return .none
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 対象のtableViewCellのStringを削除
        tableViewCell.remove(at: indexPath.row)
        
        // medicineRecordIndicesから対象のIndexを取得する
        if let index = medicineRecordIndices.firstIndex(where: { $0 == indexPath.row }) {
            let realm = try! Realm()
            if index < medicineRecordDataModel.count {
                let medicineRecord = medicineRecordDataModel[index]
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
    //        func saveMedicineRecord(_ record: MedicineRecordDataModel) {
    //            let realm = try! Realm()
    //            try! realm.write {
    //                realm.add(record, update: .modified)
    //            }
    //        }
    //        func loadMedicineRecords() -> [MedicineRecordDataModel] {
    //            let realm = try! Realm()
    //            return Array(realm.objects(MedicineRecordDataModel.self))
    //        }
    func loadSelectedDate() {
        let realm = try! Realm()
        if let medicineRecord = realm.objects(MedicineRecordDataModel.self).first {
            selectedDate = medicineRecord.date
            print("❗️読み込んだ日付 : \(selectedDate ?? Date())❗️")
        } else {
            selectedDate = nil
            print("recordが存在しません。selectedDateはnilです。")
        }
    }
    
    func saveSelectedDate(date: Date) {
        let realm = try! Realm()
        print("選択した日付 : \(date)")
        
        if let existingRecord = realm.objects(MedicineRecordDataModel.self).first {
            // 既存のレコードがある場合は、日付を更新する
            try! realm.write {
                existingRecord.date = date
                realm.add(existingRecord, update: .modified)
            }
            print("保存した日付 : \(existingRecord.date)")
        } else {
            // 既存のレコードがない場合は、新しいレコードを作成する
            let newRecord = MedicineRecordDataModel()
            newRecord.date = date
            
            try! realm.write {
                realm.add(newRecord)
            }
            print("保存した日付（新規） : \(newRecord.date)")
        }
    }
}
extension CalendarViewController: FecesDetailCellDelegate, AdditionButtonCellDelegate, MedicineAdditionViewControllerDelegate {
    func didSaveMedicineRecord(_ record: MedicineRecordDataModel) {
        //        saveData()
        
        // 既存データと重複しないようにチェック
        if !medicineRecordDataModel.contains(where: { $0.medicineName == record.medicineName && $0.timePicker == record.timePicker }) {
            medicineRecordDataModel.append(record)
            //            print("‼️開始‼️　didSaveMedicineRecord : record : \(record)") // 正常
            
            let medicineRecordCount = medicineRecordDataModel.count
            updateTableViewCells(with: medicineRecordCount)
            //            saveMedicineRecord(record)
            saveSelectedDate(date: Date())
            
            reloadData()
            
        } else {
            // 重複するデータがある場合の処理（例: ユーザーに通知）
            print("Error: The record with the same medicine name and time already exists.")
        }
    }
    
    func updateDatePicker(with date: Date) {
    }
    
    func didTapPlusButton(indexes: [Int]) {
        guard let selectedDate else { return }
        
        let realm = try! Realm()
        let model = realm.objects(FecesDetailDataModel.self)
        
        let currentTime = Date()
        
        let newData = FecesDetailDataModel(
            date: selectedDate,
            //           number: model.count,
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
    //    func saveMedicineRecordData(_ newData: MedicineRecordDataModel) {
    //        let realm = try! Realm()
    //
    //        if let data = realm.objects(MedicineRecordDataModel.self).filter("id == %@", newData.id).first {
    //            try!realm.write {
    //                data.date = newData.date
    //                data.medicineName = newData.medicineName
    //                data.textField = newData.textField
    //                data.unit = newData.unit
    //                data.timePicker = newData.timePicker
    //            }
    //        } else {
    //            try! realm.write {
    //                realm.add(newData)
    //            }
    //        }
    //    }
}

// MARK: FSCalendarDelegate関連
extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    // 日付が選択されたときに呼び出されるメソッド
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        tableView.reloadData() // 選択された日付に関連するデータを表示するためにテーブルビューをリロード
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

