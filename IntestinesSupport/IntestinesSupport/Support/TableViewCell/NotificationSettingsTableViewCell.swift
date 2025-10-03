//
//  NotificationSettingsTableViewCell.swift
//  IntestinesSupport
//
//  Created by 俺の MacBook Air on 2025/02/22.
//

import UIKit

protocol NotificationSettingsTableViewCellDelegate: AnyObject {
    func didTapedButton(in cell: NotificationSettingsTableViewCell)
}

class NotificationSettingsTableViewCell: UITableViewCell {
    
    weak var delegate: NotificationSettingsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func buttonTaped(_ sender: UIButton) {
        delegate?.didTapedButton(in: self)
    }
}
