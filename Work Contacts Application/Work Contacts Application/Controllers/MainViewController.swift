//
//  ViewController.swift
//  Work Contacts Application
//
//  Created by liene.krista.neimane on 06/08/2023.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var employeeTableView: UITableView!
    
    var tallinURL = "https://tallinn-jobapp.aw.ee/employee_list/"
    var tartuURL = "https://tartu-jobapp.aw.ee/employee_list/"
    
    // Dictionary, employees are sorted by position
    var employeesByPosition = [Position: [Employee]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Employees"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        searchBar.text = ""
        searchBar.backgroundImage = UIImage()
        
        employeeTableView.dataSource = self
        fetchEmployees()
    }
    
    
    // Fethcing all the employees to display
    func fetchEmployees() {
        let urls = [
            URL(string: tallinURL)!,
            URL(string: tartuURL)!
        ]
        
        for url in urls {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                do {
                    let employeeList = try JSONDecoder().decode(EmployeeList.self, from: data)
                    for employee in employeeList.employees {
                        self.employeesByPosition[employee.position, default: []].append(employee)
                    }
                    DispatchQueue.main.async {
                        self.employeeTableView.reloadData()
                    }
                } catch {
                    print(error)
                }
            }.resume()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Position.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let position = Position.allCases[section]
        switch position {
        case .android:
            return "Android developers"
        case .iOS:
            return "iOS developers"
        case .other:
            return "Other positions"
        case .projectManager:
            return "Project managers"
        case .sales:
            return "Sales managers"
        case .tester:
            return "Testers"
        case .web:
            return "Web developers"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let position = Position.allCases[section]
        return employeesByPosition[position]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath) as! EmployeeTableViewCell
        let position = Position.allCases[indexPath.section]
        if let employees = employeesByPosition[position] {
            let employee = employees.sorted(by: { $0.lname < $1.lname })[indexPath.row]
            cell.employeeLabel.text = "\(employee.fname) \(employee.lname)"
        }
        return cell
    }

}


// Employees
struct Employee: Codable {
    let fname: String
    let lname: String
    let contactDetails: ContactDetails
    let position: Position
    let projects: [String]?
    
    enum CodingKeys: String, CodingKey {
        case fname, lname, contactDetails = "contact_details", position, projects
    }
}

struct ContactDetails: Codable {
    let email: String
    let phone: String?
}

enum Position: String, Codable, CaseIterable {
    case android = "ANDROID"
    case iOS = "IOS"
    case other = "OTHER"
    case projectManager = "PM"
    case sales = "SALES"
    case tester = "TESTER"
    case web = "WEB"
}

struct EmployeeList: Codable {
    let employees: [Employee]
}
