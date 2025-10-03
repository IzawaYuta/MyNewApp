//
//  MemoCell.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/07/12.
//

import UIKit

class MemoCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var memo: UITextView!
    @IBOutlet weak var templateButton: UIButton!
    
    private var model: CalendarDataModel?
    private var selectedDate: Date?
    weak var delegate: CalendarViewControllerDelegate?
    private var templatePicker = ["通院", "入院", "腹痛", "", "", "", "", "", "", ""]
    private let templatePickerKey = "TemplatePickerKey"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        memo.delegate = self
        memo.isScrollEnabled = true
        memo.showsVerticalScrollIndicator = true
        memo.layer.borderColor = UIColor.systemGray.cgColor
        
        memo.layer.borderWidth = 1.0
        memo.layer.masksToBounds = true
        
        memo.textContainerInset = UIEdgeInsets(top: 8, left: 30, bottom: 8, right: 8) // 左に20ポイントのスペース
        
        setDoneButton()
        loadTemplatePicker()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func tapDoneButton() {
        self.endEditing(true)
        saveData()
    }
    
    func setDoneButton() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        let commitButton = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(tapDoneButton))
        toolBar.items = [commitButton]
        memo.inputAccessoryView = toolBar
    }
    // textViewを可変
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        if let tableView = self.superview as? UITableView {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            
            textView.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height {
                    constraint.constant = size.height
                }
            }
            tableView.endUpdates()
            
            if let indexPath = tableView.indexPath(for: self) {
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
            
            UIView.setAnimationsEnabled(true)
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
        
        let keyboardHeight = keyboardFrame.height
        let additionalMargin: CGFloat = -60
        let adjustmentHeight = willShow ? keyboardHeight + additionalMargin : 0
        let adjustmentInsets = UIEdgeInsets(top: 0, left: 0, bottom: adjustmentHeight, right: 0)
        
        if let tableView = superview as? UITableView {
            tableView.contentInset = adjustmentInsets
            tableView.scrollIndicatorInsets = adjustmentInsets
            
            if willShow {
                if let indexPath = tableView.indexPath(for: self) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
        }
    }
    
    private func saveData(selectedIndex: String = "") {
        if let model = model {
            let editModel = makeEditCalendarDataModel(memo: memo.text, model: model)
            delegate?.saveCalendarData(editModel)
        } else {
            // 新しいモデルを作成
            guard let selectedDate = selectedDate else { return }
            let newModel = makeNewCalendarDataModel(selectedDate: selectedDate, selectedIndex: memo.text)
            delegate?.saveCalendarData(newModel)
        }
    }
    
    private func makeEditCalendarDataModel(memo: String, model: CalendarDataModel) -> CalendarDataModel {
        return CalendarDataModel(
            id: model.id,
            date: model.date,
            selectedPhysicalConditionIndex: model.selectedPhysicalConditionIndex,
            selectedFecesConditionIndex: model.selectedFecesConditionIndex,
            memo: memo
        )
    }
    
    private func makeNewCalendarDataModel(selectedDate: Date, selectedIndex: String) -> CalendarDataModel {
        // 日付とButtonのIndexをセットする
        let newModel = CalendarDataModel()
        newModel.memo = String(selectedIndex)
        newModel.date = selectedDate
        return newModel
    }
    
    func configure(selectedIndex: String, model: CalendarDataModel? = nil, selectedDate: Date) {
        self.model = model
        self.selectedDate = selectedDate
        
        if let model = model {
            memo.text = model.memo // 保存されているメモを表示
        } else {
            memo.text = ""
        }
    }
    @IBAction func templateButtonTapped() {
        // 編集用のアクションを作成
        let editAction = UIAction(title: "編集", image: UIImage(systemName: "pencil")) { _ in
            self.showEditPickerAlert()
        }
        // 配列の各要素を UIAction に変換
        let actions = templatePicker.map { option in
            UIAction(title: option.isEmpty ? "" : option, attributes: option.isEmpty ? [.disabled] : []) { _ in
                if !option.isEmpty {
                    self.handleSelection(option)
                }
            }
        }
        let menu = UIMenu(title: "テンプレートを選択", options: .displayInline, children: actions + [editAction])
        // ボタンにメニューを設定
        templateButton.menu = menu
        templateButton.showsMenuAsPrimaryAction = true // ボタンをタップするとメニューを表示
    }
    private func showEditPickerAlert() {
        // アラートコントローラーを使用して選択肢を編集する
        let alert = UIAlertController(title: "テンプレートを編集", message: nil, preferredStyle: .alert)
        
        // テキストフィールドを追加
        templatePicker.enumerated().forEach { index, option in
            alert.addTextField { textField in
                textField.text = option
                textField.tag = index
            }
        }
        
        // 保存アクションを追加
        let saveAction = UIAlertAction(title: "保存", style: .default) { _ in
            // テキストフィールドの内容を取得して更新
            self.templatePicker = alert.textFields?.compactMap { $0.text } ?? []
            self.saveTemplatePicker()
            self.templateButtonTapped() // メニューを更新
        }
        
        // キャンセルアクションを追加
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        // アラートを表示
        if let viewController = delegate as? UIViewController {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    private func handleSelection(_ option: String) {
        // 既存のテキストに選択したオプションを追加
        if memo.text.isEmpty {
            memo.text = "\(option)"
        } else {
            memo.text += "、\(option)"  // 既存の内容に改行して追加
        }
        saveData(selectedIndex: option)
    }
    private func saveTemplatePicker() {
        // UserDefaults に保存
        UserDefaults.standard.set(templatePicker, forKey: templatePickerKey)
    }
    
    private func loadTemplatePicker() {
        // UserDefaults から選択肢を読み込む
        if let savedPicker = UserDefaults.standard.array(forKey: templatePickerKey) as? [String] {
            templatePicker = savedPicker
        }
    }
}
