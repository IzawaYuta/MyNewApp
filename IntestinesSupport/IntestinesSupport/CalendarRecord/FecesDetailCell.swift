//
//  FecesDetailCell.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/07/13.
//

import UIKit
import AudioToolbox

protocol FecesDetailCellDelegate: AnyObject {
    func didTapPlusButton(indexes: [Int])
    func didTapRecordButton(in cell: FecesDetailCell)
}

class FecesDetailCell: UITableViewCell {
    
    @IBOutlet weak var fecesDetail1: UIButton!
    @IBOutlet weak var fecesDetail2: UIButton!
    @IBOutlet weak var fecesDetail3: UIButton!
    @IBOutlet weak var fecesDetail4: UIButton!
    @IBOutlet weak var fecesDetail5: UIButton!
    @IBOutlet weak var fecesDetail6: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var history: UIButton!
    
    var selectedFecesDetails: [String] = ["", "", "", "", "", ""] // 追加分
    
    private var fecesDetails: [String] = ["硬便", "便秘", "普通便", "軟便", "下痢", "血便"] // 追加分
    
    private var buttons: [UIButton] {
        return [fecesDetail1, fecesDetail2, fecesDetail3, fecesDetail4, fecesDetail5, fecesDetail6]
    }
    
    private var selectedButtons: [UIButton] = []
    private var model: CalendarDataModel?
    private var selectedDate: Date?
    weak var delegate: FecesDetailCellDelegate?
    weak var delegate2: CalendarViewControllerDelegate?
    weak var fecesRecordCell: FecesRecordTableViewCell? // 追加分
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let fecesDetail: [UIButton] = [fecesDetail1, fecesDetail2, fecesDetail3, fecesDetail4, fecesDetail5, fecesDetail6]
        fecesDetailButtons(fecesDetail)
        plusButton(plusButton)
        history.addTarget(self, action: #selector(RecordButtonTapped(_:)), for: .touchUpInside)
    }
    
    private func fecesDetailButtons(_ buttons: [UIButton]) {
        for (index, button) in buttons.enumerated() { // 追加分
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .white
            button.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            
            button.layer.borderWidth = 2.0
            button.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
            
            button.layer.cornerRadius = 5.0
            button.tag = index  // ボタンにインデックスを付与　追加分
            
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        let index = sender.tag
        
        if sender.layer.borderColor == UIColor(white: 0.9, alpha: 1.0).cgColor {
            sender.layer.borderColor = UIColor(red: 0.23, green: 0.55, blue: 0.35, alpha: 1.0).cgColor
            sender.tintColor = .black
            selectedButtons.append(sender)
            selectedFecesDetails[index] = fecesDetails[index]  // ボタンが押されたら対応するテキストを保存　追加分
            
        } else {
            sender.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
            sender.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            if let index = selectedButtons.firstIndex(of: sender) {
                selectedButtons.remove(at: index)
            }
            selectedFecesDetails[index] = ""  // ボタンが解除されたらテキストをクリア　追加分
            
        }
    }
    
    private func plusButton(_ button: UIButton) {
        _ = self.plusButton.frame.width
        _ = self.plusButton.frame.height
        plusButton.setTitleColor(.black, for: .normal)
        plusButton.backgroundColor = .white
        plusButton.tintColor = .black
        plusButton.layer.cornerRadius = self.plusButton.frame.height / 2
        
        plusButton.layer.shadowColor = UIColor.black.cgColor
        plusButton.layer.shadowRadius = 3
        plusButton.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        plusButton.layer.shadowOpacity = 0.3
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        // 現在の日付と時刻を取得
        let currentDate = Date()
        
        // 日付と時刻をフォーマット
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateFormatter.dateFormat = "HH:mm"
        let timeString = dateFormatter.string(from: currentDate)
        
        if let timeDate = dateFormatter.date(from: timeString) {
            fecesRecordCell?.timePicker.date = timeDate
        } else {
            fecesRecordCell?.timePicker.date = Date()
        }
        if let cell = fecesRecordCell {
            cell.label1.text = selectedFecesDetails[0]
            cell.label2.text = selectedFecesDetails[1]
            cell.label3.text = selectedFecesDetails[2]
            cell.label4.text = selectedFecesDetails[3]
            cell.label5.text = selectedFecesDetails[4]
            cell.label6.text = selectedFecesDetails[5]
            cell.updateCount()
        } else {
        }
        
        var indexes: [Int] = []
        for button in selectedButtons {
            button.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
            button.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            indexes.append(button.tag)
        }
        delegate?.didTapPlusButton(indexes: indexes)
        showBannerMessage()
        selectedButtons.removeAll()
        selectedFecesDetails = ["", "", "", "", "", ""] // 追加分
    }
    // メッセージ
    private func showBannerMessage() {
        guard let parentView = self.superview?.superview else { return }
        
        let banner = UIView()
        banner.backgroundColor = UIColor.black
        banner.alpha = 1.0
        banner.layer.cornerRadius = 10
        banner.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(banner)
        
        let messageLabel = UILabel()
        messageLabel.text = "便の状態を記録しました"
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        banner.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            banner.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 20),
            banner.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20),
            banner.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -50),
            banner.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -10),
            messageLabel.topAnchor.constraint(equalTo: banner.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -10)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            banner.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.0, options: [], animations: {
                banner.alpha = 0.0
            }) { _ in
                banner.removeFromSuperview()
            }
        }
    }
    
    @IBAction func RecordButtonTapped(_ sender: UIButton) { // 履歴ボタン
        delegate?.didTapRecordButton(in: self)
    }
    
    private func saveData(selectedIndex: Int) {
        // modelがnilではない場合(Realmデータの編集)
        if let model {
            // indexを更新して保存する
            let editModel = makeEditCalendarDataModel(selectedIndex: selectedIndex, model: model)
            delegate2?.saveCalendarData(editModel)
        } else {
            guard let selectedDate else { return }
            // modelがnilの場合は新規作成ため、ここでModelを作成してそれを保存する
            let newModel = makeNewCalendarDataModel(selectedDate: selectedDate, selectedIndex: selectedIndex)
            delegate2?.saveCalendarData(newModel)
        }
    }
    
    private func makeEditCalendarDataModel(selectedIndex: Int, model: CalendarDataModel) -> CalendarDataModel {
        return CalendarDataModel(
            id: model.id,
            date: model.date,
            selectedPhysicalConditionIndex: model.selectedPhysicalConditionIndex,
            selectedFecesConditionIndex: model.selectedFecesConditionIndex,
            memo: model.memo
        )
    }
    
    private func makeNewCalendarDataModel(selectedDate: Date, selectedIndex: Int) -> CalendarDataModel {
        // 日付とButtonのIndexをセットする
        let newModel = CalendarDataModel()
        newModel.date = selectedDate
        return newModel
    }
    
    func configure(selectedIndex: Int = 99, model: CalendarDataModel? = nil, selectedDate: Date) {
        self.model = model
        self.selectedDate = selectedDate
        
        for (index, button) in buttons.enumerated() {
            // indexを取得し、保存していたselectedIndexと一致する場合backgroundColorをYellowにする
            button.backgroundColor = index == selectedIndex ? .systemYellow : .white
        }
    }
}
