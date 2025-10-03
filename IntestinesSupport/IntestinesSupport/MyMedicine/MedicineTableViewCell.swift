//
//  MedicineTableViewCell.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2024/08/06.
//

import UIKit

class MedicineTableViewCell: UITableViewCell {
    @IBOutlet weak var medicineNameLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var stockNumberLabel: UILabel!
    @IBOutlet weak var stockUnitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        medicineNameLabel.numberOfLines = 1 // 1行で表示する
        stockLabel.numberOfLines = 1 // 1行で表示する
        stockNumberLabel.numberOfLines = 1 // 1行で表示する
        stockUnitLabel.numberOfLines = 1 // 1行で表示する
        
        medicineNameLabel.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        medicineNameLabel.layer.cornerRadius = 7.0
        medicineNameLabel.clipsToBounds = true // labelの時は必須（角丸）
        medicineNameLabel.layer.borderColor = UIColor.red.cgColor // 枠線の色
        
        stockNumberLabel.textColor = .red
    }
}
