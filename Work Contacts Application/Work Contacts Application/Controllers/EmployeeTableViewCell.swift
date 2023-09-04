//
//  EmployeeTableViewCell.swift
//  Work Contacts Application
//
//  Created by liene.krista.neimane on 13/08/2023.
//

import UIKit

class EmployeeTableViewCell: UITableViewCell {

    @IBOutlet weak var employeeLabel: UILabel!
    @IBOutlet weak var contactButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var contactButtonTapped: (() -> Void)?
    @IBAction func contactButtonTapped(_ sender: UIButton) {
        contactButtonTapped?()
    }

}
