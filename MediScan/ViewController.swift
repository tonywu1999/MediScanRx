//
//  ViewController.swift
//  MediScan
//
//  Created by Erlun Lian on 4/13/18.
//  Copyright © 2018 Erlun Lian. All rights reserved.
//

import UIKit

// Global Variables
var my_index = 0
var is_filtered = false
var filtered_drugs = [String]() // For Filtered Table

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    

    
    @IBOutlet weak var tableView: UITableView!
    
    var searchController : UISearchController!
    var resultsController = UITableViewController()
    
    override func viewDidLoad() {
        // Establish table inside this viewcontroller
        tableView.delegate = self
        tableView.dataSource = self
        
        // Not sure why this is needed but necessary for reloading search data
        self.resultsController.tableView.delegate = self
        self.resultsController.tableView.dataSource = self
        
        self.searchController = UISearchController(searchResultsController: self.resultsController)
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false // Background is not dimmed when searching
        definesPresentationContext = true // Lack of space between search bar and content now (not working for some reason)
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // Required function by UISearchResultsUpdating.  Function called everytime someone types in something in search bar
    func updateSearchResults(for searchController: UISearchController) {
        // Filter through drug names
        
        filtered_drugs = drug_list.drugs.filter { (drug:String) -> Bool in
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
            return filtered_drugs.count
        }
        
    }
    
    // Set the height of each row:
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
    
    // Function for selection of a row to information viewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        my_index = indexPath.row
        if tableView == self.tableView {
            is_filtered = false
        }
        else {
            is_filtered = true
        }
        performSegue(withIdentifier: "info_segue", sender: self)
        
    }
    
}

