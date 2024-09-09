//
//  MedicineRecordDetailCell.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/07/12.
//

import UIKit

class MedicineRecordDetailCell: UITableViewCell {
    
    @IBOutlet weak var medicineName: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var unit: UILabel!
    
    weak var delegate: CalendarViewControllerDelegate?
    
    var selectedTime: Date {
        return timePicker.date
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        delegateSelf()
        layoutSubviews()
        setupCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    // 枠線
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // セルの横幅を調整する
        var frame = self.contentView.frame
        frame.size.width = UIScreen.main.bounds.width - 40 // 画面の幅から40ポイント引いたサイズに設定
        frame.origin.x = 20 // 左端から20ポイント内側に配置
        self.contentView.frame = frame
    }
    private func setupCell() {
        contentView.layer.borderWidth = 1.5
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.cornerRadius = 8.0
        contentView.clipsToBounds = true
    }
    func configure(with record: MedicineRecordDataModel) {
        // データモデルのプロパティを使ってセルを設定
        medicineName.text = record.medicineName
        unit.text = record.unit// 数量と単位の表示
        textField.text = "\(String(describing: textField))"
        timePicker.date = record.timePicker
    }
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
