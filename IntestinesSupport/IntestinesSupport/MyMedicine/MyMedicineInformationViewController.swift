//
//  MyMedicineInformationViewController.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/07/15.
//

import Foundation
import SwiftUI
import RealmSwift

protocol MedicineViewControllerDelegate: AnyObject {
    func didSaveMedicine(_ medicine: MedicineDataModel)
    func didDeleteMedicine(_ medicine: MedicineDataModel)
}
class MedicineDataModel: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var medicineName: String = ""
    @objc dynamic var doseNumber: Double = 0.0
    @objc dynamic var stock: Double = 0.0
    @objc dynamic var url: String = ""
    @objc dynamic var memo: String = ""
    @objc dynamic var datePickerTextField: String = ""
    @objc dynamic var textField: String = ""
    @objc dynamic var customPickerTextField: String = ""
    @objc dynamic var label: String = ""
    @objc dynamic var pickerView1: Int = 0
    @objc dynamic var pickerView2: String = ""
    @objc dynamic var datePicker: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
class MyMedicineInformation: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CalendarViewControllerDelegate {
    @IBOutlet weak var medicineNameLabel: UILabel!
    @IBOutlet weak var medicineName: UITextField!
    @IBOutlet weak var doseNumber: UITextField!
    @IBOutlet weak var stock: UITextField!
    @IBOutlet weak var url: UITextField!
    @IBOutlet weak var memo: UITextView!
    @IBOutlet weak var datePickerTextField: UITextField!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var customPickerTextField: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var delegate: MedicineViewControllerDelegate?
    var selectedMedicine: MedicineDataModel?
    
    let pickerView1 = UIPickerView()
    let pickerView2 = UIPickerView()
    let datePicker = UIDatePicker()
    let pickerData1 = ["起床時", "食前", "食直前", "食直後", "食後", "食間", "就寝前", "頓服"]
    var pickerData2 = ["錠", "包", "個", "ml", "mg"]
    var isEditingExistingMedicine = false // 編集中のフラグを設定
    var medicineDataModel: [MedicineDataModel] = []
    static let shared = MyMedicineInformation()
    var medicines: [String: Int] = [:] // medicineName: stock
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _: [UITextField] = [medicineName, url]
        
        doseNumber.keyboardType = .decimalPad
        stock.keyboardType = .decimalPad
        
        medicineName.delegate = self
        doseNumber.delegate = self
        stock.delegate = self
        url.delegate = self
        memo.delegate = self
        pickerView1.delegate = self
        pickerView1.dataSource = self
        pickerView2.delegate = self
        pickerView2.dataSource = self
        
        memo.isScrollEnabled = true  // スクロールを有効にする
        memo.textContainer.lineBreakMode = .byWordWrapping
        memo.sizeToFit()
        
        memo.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.2).cgColor
        
        memo.layer.borderWidth = 1.0
        // textFieldに収まるようにする
        medicineName.adjustsFontSizeToFitWidth = true
        medicineName.minimumFontSize = 10
        doseNumber.adjustsFontSizeToFitWidth = true
        doseNumber.minimumFontSize = 10
        stock.adjustsFontSizeToFitWidth = true
        stock.minimumFontSize = 10
        url.adjustsFontSizeToFitWidth = true
        url.minimumFontSize = 10
        
        pickerView1.showsSelectionIndicator = true
        pickerView2.showsSelectionIndicator = true
        // pickerView1をtextFieldのinputViewに設定
        textField.inputView = pickerView1
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 35))
        let doneItem = UIBarButtonItem(title: "閉じる", style: .done, target: self, action: #selector(done))
        let customItem = UIBarButtonItem(title: "編集", style: .plain, target: self, action: #selector(showCustomOption))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([doneItem, flexibleSpace, customItem], animated: true)
        customPickerTextField.inputView = pickerView2
        customPickerTextField.inputAccessoryView = toolbar
        
        loadLatestMedicine()
        resetFields()
        resetPickerView2()
        validateInput()
        createDatePicker()
        setDoneButton()
        defaultDisplay()
        updateDeleteButtonState()
        displayMedicineData()
//        customLabel()
        
        MyMedicines.loadPickerData() // データを読み込む
        pickerView2.reloadAllComponents() // pickerView を更新
        
        saveButton.isEnabled = false
        deleteButton.isEnabled = false
        
        medicineName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        if selectedMedicine != nil {
            // ボタンを有効化
            saveButton.isEnabled = true
            deleteButton.isEnabled = true
        }
    }
    
    func defaultDisplay() {
        // pickerの初期表示を設定
        let initialIndex1 = 0
        pickerView1.selectRow(initialIndex1, inComponent: 0, animated: false)
        self.textField.text = pickerData1[initialIndex1]
        
        let initialIndex2 = 0
        pickerView2.selectRow(initialIndex2, inComponent: 0, animated: false)
        self.customPickerTextField.text = pickerData2[initialIndex2]
    }
    
    @objc func tapDoneButton() {
        self.view.endEditing(true)
    }
    
    func setDoneButton() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        let commitButton = UIBarButtonItem(title: "閉じる", style: .done, target: self, action: #selector(tapDoneButton))
        toolBar.items = [commitButton]
        medicineName.inputAccessoryView = toolBar
        doseNumber.inputAccessoryView = toolBar
        stock.inputAccessoryView = toolBar
        url.inputAccessoryView = toolBar
        memo.inputAccessoryView = toolBar
        textField.inputAccessoryView = toolBar
    }
    // キーボード追従
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == memo {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == memo {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            textView.scrollRangeToVisible(NSRange(location: 0, length: 0))
        }
    }
    // キーボード追従
    @objc func keyboardWillShow(_ notification: Notification) {
        adjustForKeyboard(notification: notification, willShow: true)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustForKeyboard(notification: notification, willShow: false)
    }
    
    func adjustForKeyboard(notification: Notification, willShow: Bool) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard memo.isFirstResponder else { return }
        let keyboardHeight = keyboardFrame.height
        let additionalMargin: CGFloat = -100
        let adjustmentHeight = willShow ? keyboardHeight + additionalMargin : 0
        UIView.animate(withDuration: 0.3) {
            if let scrollView = self.view as? UIScrollView {
                scrollView.contentInset.bottom = adjustmentHeight
                scrollView.scrollIndicatorInsets.bottom = adjustmentHeight
            } else {
                self.view.frame.origin.y = willShow ? -adjustmentHeight : 0
            }
        }
    }
    // DatePicker
    private func createDatePicker(){
        // DatePickerModeをDate(日付)に設定
        datePicker.datePickerMode = .time
        // DatePickerを日本語化
        datePicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        // textFieldのinputViewにdatepickerを設定
        datePickerTextField.inputView = datePicker
        // UIToolbarを設定
        let toolbar3 = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 35))
        let resetItem3 = UIBarButtonItem(title: "クリア", style: .plain, target: self, action: #selector(resetOption))
        let flexibleSpace3 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        // Doneボタンを設定(押下時doneClickedが起動)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(doneClicked))
        // Doneボタンを追加
        toolbar3.setItems([doneButton, flexibleSpace3, resetItem3], animated: true)
        // FieldにToolbarを追加
        datePickerTextField.inputAccessoryView = toolbar3
        // Pickerのスタイルをホイールに設定
        datePicker.preferredDatePickerStyle = .wheels
    }
    
    @objc func doneClicked(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        // textFieldに選択した日付を代入
        datePickerTextField.text = dateFormatter.string(from: datePicker.date)
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerView1 {
            return pickerData1.count
        } else if pickerView == pickerView2 {
            return MyMedicines.sharedPickerData2.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerView1 {
            return pickerData1[row]
        } else if pickerView == pickerView2 {
            return MyMedicines.sharedPickerData2[row]
        } else {
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerView1 {
            self.textField.text = pickerData1[row]
        } else if pickerView == pickerView2 {
            guard row < MyMedicines.sharedPickerData2.count else { return }  // インデックスチェック
            let selectedValue = MyMedicines.sharedPickerData2[row]  // 最新のデータを使用
            self.customPickerTextField.text = selectedValue
            self.label.text = selectedValue  // 選んだ値がUILabelに反映
        }
    }
    // カスタムアラートの作成
    @objc func showCustomOption() {
        let alert = UIAlertController(title: "カスタム", message: "選択してください", preferredStyle: .actionSheet)
        
        let addAction = UIAlertAction(title: "新規追加", style: .default) { [weak self] _ in
            self?.showAddCustomOptionAlert()
        }
        let selectedRow = pickerView2.selectedRow(inComponent: 0)
        let selectedOptions = MyMedicines.sharedPickerData2[selectedRow]
        let deleteAction = UIAlertAction(title: "「\(selectedOptions)」を削除", style: .destructive) { [weak self] _ in
            self?.showDeleteCustomOptionAlert()
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    // 新規追加アラート
    func showAddCustomOptionAlert() {
        let alert = UIAlertController(title: "新規追加", message: "オプションを追加してください", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "新しいオプション"
        }
        let addAction = UIAlertAction(title: "追加", style: .default) { [weak self] _ in
            if let newOption = alert.textFields?.first?.text, !newOption.isEmpty {
                MyMedicines.addPickerData(item: newOption)  // ここでメソッドを呼び出す
                self?.pickerView2.reloadAllComponents()
                self?.resetPickerView2()
                let newIndex = self?.pickerData2.count ?? 1 - 1
                self?.pickerView2.selectRow(newIndex, inComponent: 0, animated: false)
                self?.customPickerTextField.text = newOption
                self?.label.text = newOption
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    // 削除アラート
    func showDeleteCustomOptionAlert() {
        guard pickerData2.count > 1 else { return }
        let selectedRow = pickerView2.selectedRow(inComponent: 0)
        let selectedOption = pickerData2[selectedRow]
        let selectedOptions = MyMedicines.sharedPickerData2[selectedRow]
        guard selectedRow < pickerData2.count else { return }
        let alert = UIAlertController(title: "「\(selectedOptions)」を削除しますか？", message: nil, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "削除", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            // 選択肢を削除
            MyMedicines.removePickerData(at: selectedRow)
            
            // PickerViewを再ロード
            self.pickerView2.reloadAllComponents()
            
            // インデックスを 0 に設定
            self.pickerView2.selectRow(0, inComponent: 0, animated: true)
            
            // 新たに選択された値を `sharedPickerData2` から取得してフィールドに設定
            let newSelectedValue = MyMedicines.sharedPickerData2.isEmpty ? "" : MyMedicines.sharedPickerData2[0]
            self.customPickerTextField.text = newSelectedValue
            self.label.text = newSelectedValue
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func done() {
        self.view.endEditing(true)
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func resetOption() {
        datePickerTextField? .text = ""
        datePicker.setDate(Date(), animated: false)
        self.view.endEditing(true)
    }
    
    func customTextField(_ textFields: [UITextField], _ textView: UITextView) {
        textFields.forEach { textField in
            textField.autocorrectionType = .no // オートコレクトを無効
            textField.autocapitalizationType = .none // 大文字小文字の自動変換を無効
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 現在のテキストを取得
        let currentText = textField.text ?? ""
        // 入力後のテキストを計算
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        // 小数点の数をカウント
        let dotCount = updatedText.filter { $0 == "." }.count
        
        if textField == doseNumber {
            // 小数点が1つ以下のときは許可
            return dotCount <= 1
        }
        if textField == stock {
            return dotCount <= 1
        }
        return true // その他のテキストフィールドの場合はデフォルトで許可
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        let medicine = MedicineDataModel()
        medicine.medicineName = medicineName.text ?? ""
        if let doseNumberText = doseNumber.text, let doseNumberValue = Double(doseNumberText) {
            medicine.doseNumber = doseNumberValue
        } else {
            medicine.doseNumber = 0
        }
        if let stockText = stock.text, let stockValue = Double(stockText) {
            medicine.stock = stockValue
        } else {
            medicine.stock = 0
        }
        medicine.url = url.text ?? ""
        medicine.memo = memo.text ?? ""
        medicine.datePickerTextField = datePickerTextField.text ?? ""
        medicine.textField =  textField.text ?? ""
        medicine.customPickerTextField =  customPickerTextField.text ?? ""
        medicine.label = label.text ?? ""
        let selectedRow1 = pickerView1.selectedRow(inComponent: 0)
        medicine.pickerView1 = selectedRow1
        
        let selectedRow2 = pickerView2.selectedRow(inComponent: 0)
        if selectedRow2 >= 0 && selectedRow2 < pickerData2.count {
            let selectedValue = pickerData2[selectedRow2]
            medicine.pickerView2 = selectedValue
        }
        medicine.datePicker = datePicker.date
        
        let realm = try! Realm()
        
        // 重複チェック
        let existingMedicine = realm.objects(MedicineDataModel.self).filter("medicineName == %@", medicineName.text ?? "").first
        
        if !isEditingExistingMedicine {
            let existingMedicine = realm.objects(MedicineDataModel.self).filter("medicineName == %@", medicine.medicineName).first
            if existingMedicine != nil {
                // アラートを表示
                let alert = UIAlertController(title: "エラー", message: "同じ名前の薬が保存されています。\n別の名前を入力してください。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
        }
        
        try! realm.write {
            realm.add(medicine)
        }
        print("保存成功: stock = \(medicine.stock), doseNumber = \(medicine.doseNumber)")
        delegate?.didSaveMedicine(medicine)
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil) // モーダル画面を閉じる
        
        isEditingExistingMedicine = false // 保存後にフラグをリセット
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        let medicineData = MedicineDataModel()
        let alertMessage = UIAlertController(title: "このページを削除しますか", message: nil, preferredStyle: .alert)
        let deleteButton = UIAlertAction(title: "削除", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            resetFields()
            resetPickerView2()
            
            if let medicine = selectedMedicine {
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(medicine)
                }
                delegate?.didDeleteMedicine(medicine)
                
                navigationController?.popViewController(animated: true)
                dismiss(animated: true, completion: nil) // モーダル画面を閉じる
            }
        }
        
        let cancelButton = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertMessage.addAction(deleteButton)
        alertMessage.addAction(cancelButton)
        
        present(alertMessage, animated: true, completion: nil)
    }
    
    func loadLatestMedicine() {
        let realm = try! Realm()
        let medicines = realm.objects(MedicineDataModel.self)
        // Realmからデータを読み込む
        if let latestMedicine = medicines.last {
            medicineName.text = latestMedicine.medicineName
            if latestMedicine.doseNumber == Double(Int(latestMedicine.doseNumber)) {
                doseNumber.text = "\(Int(latestMedicine.doseNumber))" // ０の場合整数として表示
            } else {
                doseNumber.text = "\(latestMedicine.doseNumber)" // 小数としてそのまま表示
            }
            if latestMedicine.stock == Double(Int(latestMedicine.stock)) {
                stock.text = "\(Int(latestMedicine.stock))" // ０の場合整数として表示
            } else {
                stock.text = "\(latestMedicine.stock)" // 小数としてそのまま表示
            }
            url.text = latestMedicine.url
            memo.text = latestMedicine.memo
            datePickerTextField.text = latestMedicine.datePickerTextField
            textField.text = latestMedicine.textField
            customPickerTextField.text = latestMedicine.customPickerTextField
            label.text = latestMedicine.label
            pickerView1.selectRow(latestMedicine.pickerView1, inComponent: 0, animated: false)
            
            if let index = pickerData2.firstIndex(of: latestMedicine.pickerView2) {
                pickerView2.selectRow(index, inComponent: 0, animated: false)
            }
            datePicker.setDate(latestMedicine.datePicker, animated: false)
        }
    }
    // 入力欄をリセット
    func resetFields() {
        medicineName? .text = ""
        doseNumber? .text = ""
        stock? .text = ""
        url? .text = ""
        memo? .text = ""
        datePickerTextField? .text = ""
        textField? .text = ""
        customPickerTextField? .text = ""
        label? .text = ""
        pickerView1.selectRow(0, inComponent: 0, animated: false)
        textField.text = pickerData1[0]
        datePicker.setDate(Date(), animated: false)
        datePickerTextField.text = ""
    }
    
    func resetPickerView2() {
        guard !pickerData2.isEmpty else {
            return
        }
        pickerView2.selectRow(0, inComponent: 0, animated: false)
        customPickerTextField.text = pickerData2[0]
        label.text = pickerData2[0]
    }
    // TextFieldに打ち込まれてないときにボタンを非活性
    @objc private func textFieldDidChange(_ sender: Any) {
        validateInput()
    }
    
    private func validateInput() {
        let isMedicineNameEmpty = medicineName.text?.isEmpty ?? true
        saveButton.isEnabled = !isMedicineNameEmpty
    }
    // 入力されていなかったら削除ボタンを非活性
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateDeleteButtonState()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateDeleteButtonState()
    }
    
    func updateDeleteButtonState() {
        let isMedicineNameFilled = !(medicineName.text?.isEmpty ?? true)
        let isDoseNumberFilled = !(doseNumber.text?.isEmpty ?? true)
        let isStockFilled = !(stock.text?.isEmpty ?? true)
        let isUrlFilled = !(url.text?.isEmpty ?? true)
        let isMemoFilled = !(memo.text?.isEmpty ?? true)
        let isDatePickerTextFieldFilled = !(datePickerTextField.text?.isEmpty ?? true)
        
        deleteButton.isEnabled = (isMedicineNameFilled || isDoseNumberFilled || isStockFilled || isUrlFilled || isMemoFilled || isDatePickerTextFieldFilled)
    }
    // 保存されたデータを表示
    private func displayMedicineData() {
        guard let medicine = selectedMedicine else { return }
        
        medicineName.text = medicine.medicineName
        if medicine.doseNumber == 0 {
            doseNumber.text = "0"
        } else if medicine.doseNumber.truncatingRemainder(dividingBy: 1) == 0 {
            doseNumber.text = "\(Int(medicine.doseNumber))"
        } else {
            doseNumber.text = "\(medicine.doseNumber)"
        }
        if medicine.stock == 0 {
            stock.text = "0"
        } else if medicine.stock.truncatingRemainder(dividingBy: 1) == 0 {
            stock.text = "\(Int(medicine.stock))"
        } else {
            stock.text = "\(medicine.stock)"
        }
        url.text = medicine.url
        memo.text = medicine.memo
        datePickerTextField.text = medicine.datePickerTextField
        textField.text = medicine.textField
        customPickerTextField.text = medicine.customPickerTextField
        label.text = medicine.label
        
        pickerView1.selectRow(medicine.pickerView1, inComponent: 0, animated: false)
        
        if let index = pickerData2.firstIndex(of: medicine.pickerView2) {
            pickerView2.selectRow(index, inComponent: 0, animated: false)
        }
        
        datePicker.setDate(medicine.datePicker, animated: false)
    }
    func saveCalendarData(_ calendar: CalendarDataModel) {
        // 使用しない
    }
//    private func customLabel() {
//        // 背景ビューの作成
//        let backgroundView = UIView()
//        backgroundView.backgroundColor = .red  // 好みの色に変更してください
//        backgroundView.translatesAutoresizingMaskIntoConstraints = false
//        
//        // 背景ビューのサイズや位置を数値で管理
//                let backgroundWidth: CGFloat = 100    // 背景ビューの幅
//                let backgroundHeight: CGFloat = 15    // 背景ビューの高さ
//                let verticalSpacing: CGFloat = -20     // 背景ビューの`medicineLabel`からの縦の間隔
//
//                // medicineLabelの背後に配置
//                view.insertSubview(backgroundView, belowSubview: medicineNameLabel)
//                
//                // Auto Layout制約の設定
//                NSLayoutConstraint.activate([
//                    // 幅と高さを数値で指定
//                    backgroundView.widthAnchor.constraint(equalToConstant: backgroundWidth),
//                    backgroundView.heightAnchor.constraint(equalToConstant: backgroundHeight),
//                    
//                    // 背景ビューの水平方向の位置を`medicineLabel`に合わせる
//                    backgroundView.centerXAnchor.constraint(equalTo: medicineNameLabel.centerXAnchor),
//                    
//                    // 背景ビューの位置を`medicineLabel`の下に合わせて、間隔を指定
//                    backgroundView.topAnchor.constraint(equalTo: medicineNameLabel.bottomAnchor, constant: verticalSpacing)
//                ])
//    }
}
