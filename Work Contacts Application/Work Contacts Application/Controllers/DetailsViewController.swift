//
//  DetailsViewController.swift
//  Work Contacts Application
//
//  Created by liene.krista.neimane on 06/08/2023.
//

import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var positionTitleLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    
    @IBOutlet weak var emailTitleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var phoneTitleLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var projectTableView: UITableView!
    
    var employee: Employee?
    var projects: [String]?
    
    override func viewDidLoad() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        //self.navigationController?.navigationBar.text = "Cancel"
        self.navigationController?.navigationBar.tintColor = UIColor.systemYellow
        
        if let employee = employee {
            
            nameLabel.text = "\(employee.fname) \(employee.lname)"
            
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
            
            emailLabel.text = employee.contactDetails.email
            
            // Set or hide the phone labels
            if let phone = employee.contactDetails.phone {
                phoneTitleLabel.isHidden = false
                phoneLabel.isHidden = false
                phoneLabel.text = phone
            } else {
                phoneTitleLabel.isHidden = true
                phoneLabel.isHidden = true
                
                // Move the table view up
                projectTableView.frame.origin.y -= phoneTitleLabel.frame.height + phoneLabel.frame.height
            }
            
            projects = employee.projects
        }
    }
    
}


extension DetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as! ProjectTableViewCell
        cell.projectLabel.text = projects?[indexPath.row]
        return cell
    }
}
