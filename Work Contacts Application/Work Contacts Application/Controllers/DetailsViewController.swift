//
//  DetailsViewController.swift
//  Work Contacts Application
//
//  Created by liene.krista.neimane on 06/08/2023.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var employeeName: UINavigationItem!
    @IBOutlet weak var positionLabel: UILabel!
    
    var employee: Employee?
    
    override func viewDidLoad() {
        // Update the UI with the selected employee's information
        if let employee = employee {
            employeeName.title = "\(employee.fname) \(employee.lname)"
            switch employee.position {
            case .android:
                positionLabel.text = "Android Developer"
            case .iOS:
                positionLabel.text = "iOS Developer"
            case .other:
                positionLabel.text = "Other"
            case .projectManager:
                positionLabel.text = "Project Manager"
            case .sales:
                positionLabel.text = "Sales Manager"
            case .tester:
                positionLabel.text = "Tester"
            case .web:
                positionLabel.text = "Web Developer"
            }
        }
    }
    
}
