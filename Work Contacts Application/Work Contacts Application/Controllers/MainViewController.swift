//
//  ViewController.swift
//  Work Contacts Application
//
//  Created by liene.krista.neimane on 06/08/2023.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var employeeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Employees"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        searchBar.text = ""
        searchBar.backgroundImage = UIImage()
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showDetails" {
//            let detailsViewController = segue.destination as! DetailsViewController
//        }
//    }

}

