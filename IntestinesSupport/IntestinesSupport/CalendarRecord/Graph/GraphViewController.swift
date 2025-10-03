//
//  GraphViewController.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/10/16.
//

import Foundation
import UIKit
import DGCharts
import RealmSwift

class GraphViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var barItem: UIBarItem!
    
    var textField = UITextField()
    var graphView = LineChartView()
    
    var recordList: [FecesDetailDataModel] = []
    
    let years = (2000...2030).map { $0 }
    let months = (1...12).map { $0 }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        graphView.frame = CGRect(x: 0, y: 155, width: 420, height: 680)
        view.addSubview(graphView)
        navigationController?.navigationBar.isHidden = false
        
        barItem.isEnabled = false
        
        // グラフをセットアップ
        setupGraph()
        
        // 現在の日付を取得
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        let currentDateString = formatter.string(from: currentDate)
        
        // UITextField の設定
        textField = UITextField(frame: CGRect(x: (view.bounds.size.width - 100) / 2, y: 116, width: 200, height: 36))
        textField.borderStyle = .none // 枠線を消す
        textField.tintColor = .clear // カーソルを非表示にする
        textField.text = currentDateString // 初期表示を現在の日付に設定
        textField.placeholder = "年と月を選択"
        
        let pickerView = UIPickerView()
        pickerView.backgroundColor = UIColor.white
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.tag = 1 // PickerView 識別用
        textField.inputView = pickerView
        view.addSubview(textField)
        
        // PickerView の初期選択を設定
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        pickerView.selectRow(currentYear - 2000, inComponent: 0, animated: false) // 年
        pickerView.selectRow(currentMonth - 1, inComponent: 1, animated: false) // 月
        
        fetchFecesData(forYear: currentYear, month: currentMonth) //グラフの初期表示を現在に
        
        setKeyboardAccessory()
        hidePickerView()
        
    }
    
    // 指定された年と月のデータを取得する
    func fetchFecesData(forYear year: Int, month: Int) {
        recordList.removeAll()
        let realm = try! Realm()
        let calendar = Calendar.current
        
        // 現在の年と月の初日と最終日を取得
        let startDate = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        let endDate = calendar.date(from: DateComponents(year: year, month: month, day: range.count))!
        
        // Realmで指定された期間のデータを取得
        let fecesData = realm.objects(FecesDetailDataModel.self).filter("date >= %@ AND date <= %@", startDate, endDate)
        
        // recordList にデータを保存
        recordList = Array(fecesData)
        setupGraph()
    }
    
    func setupGraph() {
        var dataEntries: [ChartDataEntry] = []
        let calendar = Calendar.current
        let currentDate = Date()
        
        // 1ヶ月間の日付を作成（初期化）
        var dailyCount: [Int: Int] = [:]
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 31
        for dayOffset in 0..<31 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: currentDate) {
                let day = calendar.component(.day, from: date)
                dailyCount[day] = 0 // データがない日は0を初期化
            }
        }
        
        // データがある日をカウント
        for fecesData in recordList {
            let day = calendar.component(.day, from: fecesData.date)
            dailyCount[day, default: 0] += 1
        }
        
        // データエントリを作成
        for dayOffset in 1...31 {
            let count = dailyCount[dayOffset] ?? 0
            let dataEntry = ChartDataEntry(x: Double(dayOffset), y: Double(count))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "便の回数")
        let chartData = LineChartData(dataSet: chartDataSet)
        
        chartDataSet.colors = [NSUIColor.red]
        chartDataSet.circleColors = [NSUIColor.red]
        chartDataSet.drawValuesEnabled = false //グラフ中の数字を表示
        //        chartDataSet.valueFont = UIFont.systemFont(ofSize: 9) // 数値のフォントサイズ変更
        chartDataSet.circleRadius = 4.0
        chartDataSet.circleHoleColor = .red.withAlphaComponent(1.0)
        
        // グラフにデータをセット
        graphView.data = chartData
        
        // グラフの追加設定
        graphView.xAxis.labelPosition = .bottom
        graphView.xAxis.granularity = 1.0 // X軸の間隔
        graphView.rightAxis.enabled = false // 右側のY軸を無効化
        
        //横軸の設定
        graphView.xAxis.axisMinimum = 1
        graphView.xAxis.axisMaximum = 31
        graphView.xAxis.labelCount = daysInMonth // ラベルの数を月の日数に合わせる
        
        // 縦軸の設定
        graphView.leftAxis.labelPosition = .outsideChart
        graphView.leftAxis.axisMinimum = 0 // Y軸の最小値を0に固定
        graphView.leftAxis.granularity = 1.0 // Y軸の間隔を1に設定
        //        graphView.leftAxis.forceLabelsEnabled = true // ラベルが強制的に表示されるようにする
        
        // 5の倍数の縦線を赤色で表示
        for day in stride(from: 5, to: 32, by: 5) {
            let limitLine = ChartLimitLine(limit: Double(day), label: "")
            limitLine.lineColor = .black.withAlphaComponent(0.7)
            limitLine.lineWidth = 1.0
            graphView.xAxis.addLimitLine(limitLine)
        }
        
        for time in stride(from: 5, to: 100, by: 5) {
            let limitLine = ChartLimitLine(limit: Double(time), label: "")
            limitLine.lineColor = .black.withAlphaComponent(0.7)
            limitLine.lineWidth = 1.0
            graphView.leftAxis.addLimitLine(limitLine)
        }
        
        for time in stride(from: 1, to: 100, by: 1) {
            let limitLine = ChartLimitLine(limit: Double(time), label: "")
            limitLine.lineColor = .black.withAlphaComponent(0.3)
            limitLine.lineWidth = 0.3
            graphView.leftAxis.addLimitLine(limitLine)
        }
        // 凡例を非表示
        graphView.legend.enabled = false
        // タップでプロットを選択できないようにする
        graphView.highlightPerTapEnabled = false
        // ピンチズームオフ
        graphView.pinchZoomEnabled = false
        // ダブルタップズームオフ
        graphView.doubleTapToZoomEnabled = false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return years.count
        } else if component == 1 {
            return months.count
        } else {
            return 0
        }
    }
    
    // MARK: - UIPickerView delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(years[row])年"
        } else if component == 1 {
            return "\(months[row])月"
        } else {
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let year = years[pickerView.selectedRow(inComponent: 0)]
        let month = months[pickerView.selectedRow(inComponent: 1)]
        textField.text = "\(year)年 \(month)月"
        
        fetchFecesData(forYear: year, month: month)
    }
    
    func setKeyboardAccessory() {
        let keyboardAccessory = UIView(frame: CGRectMake(0, 0, view.bounds.size.width, 36))
        keyboardAccessory.backgroundColor = UIColor.white
        textField.inputAccessoryView = keyboardAccessory
        
        let topBorder = UIView(frame: CGRectMake(0, 0, keyboardAccessory.bounds.size.width, 0.5))
        topBorder.backgroundColor = UIColor.lightGray
        keyboardAccessory.addSubview(topBorder)
        
        let completeButton = UIButton(frame: CGRectMake(keyboardAccessory.bounds.size.width - 48, 0, 48, keyboardAccessory.bounds.size.height - 0.5 * 2))
        completeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        completeButton.setTitle("完了", for: .normal)
        completeButton.setTitleColor(UIColor.blue, for: .normal)
        completeButton.setTitleColor(UIColor.red, for: .highlighted)
        completeButton.addTarget(self, action: Selector("hidePickerView"), for: .touchUpInside)
        keyboardAccessory.addSubview(completeButton)
        
        let bottomBorder = UIView(frame: CGRectMake(0, keyboardAccessory.bounds.size.height - 0.5, keyboardAccessory.bounds.size.width, 0.5))
        bottomBorder.backgroundColor = UIColor.lightGray
        keyboardAccessory.addSubview(bottomBorder)
    }
    
    @objc func hidePickerView() {
        textField.resignFirstResponder()
    }
}
