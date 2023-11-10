//
//  ViewController.swift
//  Work Contacts Application
//
//  Created by liene.krista.neimane on 06/08/2023.
//

import UIKit
import Contacts
import ContactsUI

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var employeeTableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var tallinURL = "https://tallinn-jobapp.aw.ee/employee_list/"
    var tartuURL = "https://tartu-jobapp.aw.ee/employee_list/"
    
    // Dictionary, employees are sorted by position
    var employeesByPosition = [Position: [Employee]]()
    var allEmployees: [Employee] = []
    var matchingContact: CNContact?
    var allContacts: [CNContact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Employees"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        configureSearchBar()
        
        cancelButton.isHidden = true
        
        employeeTableView.delegate = self
        employeeTableView.dataSource = self
        
        setupRefresh()
        fetchEmployees()
        //
        fetchAllContacts()
        
        let contactStore = CNContactStore()
        contactStore.requestAccess(for: .contacts) { granted, error in }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let backItem = UIBarButtonItem()
            backItem.title = "Employees"
            navigationItem.backBarButtonItem = backItem
            if let detailsViewController = segue.destination as? DetailsViewController,
               let indexPath = employeeTableView.indexPathForSelectedRow,
               let employees = employeesByPosition[Position.allCases[indexPath.section]] {
                detailsViewController.employee = employees.sorted(by: { $0.lname < $1.lname })[indexPath.row]
            }
        }
    }
    
    
    // Extracting information from JSON, then displaying in collection view
    func fetchEmployees() {
        let urls = [
            URL(string: tallinURL)!,
            URL(string: tartuURL)!
        ]
        
        // Resetting employees list
        allEmployees = []
        employeesByPosition = [:]
        
        for url in urls {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.showError()
                    }
                    print("Error: \(error)!")
                    return
                }
                
                guard let data = data else { return }
                
                //Parsing JSON
                do {
                    let employeeList = try JSONDecoder().decode(EmployeeList.self, from: data)
                    for employee in employeeList.employees {
                        // Check for duplicates
                        if !self.allEmployees.contains(where: { $0.fname == employee.fname && $0.lname == employee.lname }) {
                            self.allEmployees.append(employee)
                            self.employeesByPosition[employee.position, default: []].append(employee)
                        }
                    }
                    DispatchQueue.main.async {
                        self.employeeTableView.reloadData()
                    }
                } catch {
                    print(error)
                    DispatchQueue.main.async {
                        self.showError()
                    }
                }
            }.resume()
        }
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.cancelButton.isHidden = true
            self.searchBar.text = ""
            self.searchBar.resignFirstResponder()
        }
        // Cancel button refreshes the table view
        searchBar(searchBar, textDidChange: "")
    }

}


extension MainViewController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath) as! EmployeeTableViewCell
        let position = Position.allCases[indexPath.section]
        if let employees = employeesByPosition[position] {
            // Sorted by last name
            let employee = employees.sorted(by: { $0.lname < $1.lname })[indexPath.row]
            // Prints out last name before first name
            cell.employeeLabel.text = "\(employee.lname) \(employee.fname)"
            
            // Check for matching contact for the employee
            if let matchingContact = allContacts.first(where: { contact in
                contact.givenName.caseInsensitiveCompare(employee.fname) == .orderedSame &&
                    contact.familyName.caseInsensitiveCompare(employee.lname) == .orderedSame
            }) {
                // Show the contact button and set its action if a matching contact is found
                cell.contactButton.isHidden = false
                cell.contactButtonTapped = { [weak self] in
                    guard let self = self else { return }
                    let contactViewController = CNContactViewController(for: matchingContact)
                    contactViewController.allowsEditing = false
                    self.navigationController?.pushViewController(contactViewController, animated: true)
                }
            } else {
                // Hide the contact button if no match is found
                cell.contactButton.isHidden = true
            }
        }
        
        return cell
    }

    
    func checkForMatchingContact(for employee: Employee, completion: @escaping (CNContact?) -> Void) {
        // Check if the user has authorized access to Contacts
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        guard authorizationStatus == .authorized else {
            // If access is not authorized
            completion(nil)
            return
        }
        let contactStore = CNContactStore()
        let predicate = CNContact.predicateForContacts(matchingName: "\(employee.fname) \(employee.lname)")
        let keysToFetch: [CNKeyDescriptor] = [CNContactGivenNameKey as CNKeyDescriptor,
                                              CNContactFamilyNameKey as CNKeyDescriptor,
                                              CNContactViewController.descriptorForRequiredKeys()]
        do {
            // Fetch the matching contacts
            let matchingContacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            completion(matchingContacts.first)
        } catch {
            print("Error fetching contacts: \(error)")
            completion(nil)
        }
    }
    
    func fetchAllContacts() {
        let contactStore = CNContactStore()
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            DispatchQueue.global(qos: .userInitiated).async {
                let keys: [CNKeyDescriptor] = [CNContactGivenNameKey as CNKeyDescriptor,
                                               CNContactFamilyNameKey as CNKeyDescriptor,
                                               CNContactViewController.descriptorForRequiredKeys()]
                let request = CNContactFetchRequest(keysToFetch: keys)
                
                do {
                    try contactStore.enumerateContacts(with: request) { (contact, stop) in
                        self.allContacts.append(contact)
                    }
                } catch {
                    print("Failed to fetch contact, error: \(error)")
                }
            }
            
        case .notDetermined:
            contactStore.requestAccess(for: .contacts) { (granted, error) in
                if granted {
                    self.fetchAllContacts()
                }
            }
            
        default:
            print("Not handled")
        }
    }


}



extension MainViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Position.allCases.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetails", sender: self)
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
    
    // Fethcing all the employees to display
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        employeesByPosition = [:]
        let searchTerms = searchText.split(separator: " ").map { String($0) }
        for employee in allEmployees {
            if searchText.isEmpty || searchTerms.allSatisfy({ searchTerm in
                employee.fname.lowercased().contains(searchTerm.lowercased()) ||
                employee.lname.lowercased().contains(searchTerm.lowercased()) ||
                employee.contactDetails.email.lowercased().contains(searchTerm.lowercased()) ||
                employee.position.rawValue.lowercased().contains(searchTerm.lowercased()) ||
                (employee.projects?.contains(where: { $0.lowercased().contains(searchTerm.lowercased()) }) ?? false)
            }) {
                self.employeesByPosition[employee.position, default: []].append(employee)
            }
        }
        employeeTableView.reloadData()
    }
    
    func configureSearchBar() {
        searchBar.delegate = self
        searchBar.text = ""
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.clearButtonMode = .never
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3) {
            self.cancelButton.isHidden = false
        }
    }
    
    @objc func refreshData() {
        fetchEmployees()
        employeeTableView.refreshControl?.endRefreshing()
    }
    
    func setupRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        employeeTableView.refreshControl = refreshControl
    }
    
    // Error shown to user
    func showError() {
        let alert = UIAlertController(title: "Error fetching data!", message: "Please try again!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
}



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
