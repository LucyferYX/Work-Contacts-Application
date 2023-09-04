//
//  DetailsViewController.swift
//  Work Contacts Application
//
//  Created by liene.krista.neimane on 06/08/2023.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var positionTitleLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    
    @IBOutlet weak var emailTitleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var phoneTitleLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var phoneToTableConstraint: NSLayoutConstraint!
    @IBOutlet weak var projectTableView: UITableView!
    
    var employee: Employee?
    var projects: [String]?
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.tintColor = UIColor.systemYellow
        projectTableView.dataSource = self
        projectTableView.delegate = self
        
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
                phoneToTableConstraint.constant -= phoneTitleLabel.frame.height + phoneLabel.frame.height + emailLabel.frame.height
            }
            
            projects = employee.projects
            
            if ((employee.projects?.isEmpty) == nil) {
                projectTableView.isHidden = true
            }
        }
    }
    
}


extension DetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Projects"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as! ProjectTableViewCell
        cell.projectLabel.text = projects?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .systemGray6
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        // Padding
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        ])
        
        return view
    }
}
