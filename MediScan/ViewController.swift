//
//  ViewController.swift
//  MediScan
//
//  Created by Erlun Lian on 4/13/18.
//  Copyright © 2018 Erlun Lian. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    

    // Might be different since tableview is inside viewcontroller
    @IBOutlet weak var tableView: UITableView!
    var drug_list = Drugs()
    var filtered_drugs = [String]() // For Filtered Table
    
    var searchController : UISearchController!
    var resultsController = UITableViewController()
    
    override func viewDidLoad() {
        // Establish table inside this viewcontroller
        tableView.delegate = self
        tableView.dataSource = self
        
        // Not sure why this is needed but necessary for reloading search data
        self.resultsController.tableView.delegate = self
        self.resultsController.tableView.dataSource = self
        
        drug_list.set_up_dictionary() // Set up dictionary function.  Probably can execute during initialization
        
        self.searchController = UISearchController(searchResultsController: self.resultsController)
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false // Background is not dimmed when searching
        definesPresentationContext = true // Lack of space between search bar and content now
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // Required function by UISearchResultsUpdating.  Function called everytime someone types in something in search bar
    func updateSearchResults(for searchController: UISearchController) {
        // Filter through drug names
        
        self.filtered_drugs = self.drug_list.drugs.filter { (drug:String) -> Bool in
            if drug.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil {
                return true
            }
            else {
                return false
            }
        }
        
        // Update the results table view
        self.resultsController.tableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns number of Rows in each section
        if tableView == self.tableView {
            return drug_list.main_usages.count
        }
        else {
            return self.filtered_drugs.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create a UI Table View for each drug
        
        
        
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
            cell.cellView.layer.cornerRadius = cell.cellView.frame.height/2
            cell.drug_label.text = drug_list.drugs[indexPath.row]
            return cell
        }
        else {
            let cell = UITableViewCell()
            cell.textLabel?.text = filtered_drugs[indexPath.row]
            return cell
        }
        
        
        
    }

   
    
}

