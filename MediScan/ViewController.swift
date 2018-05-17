//
//  ViewController.swift
//  MediScan
//
//  Created by Erlun Lian on 4/13/18.
//  Copyright © 2018 Erlun Lian. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    var drug_list = Drugs()
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        drug_list.set_up_dictionary() // Set up dictionary function.  Probably can execute during initialization
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns number of Rows in each section
        return drug_list.main_usages.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create a UI Table View for each drug
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
        
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height/2
        cell.drug_label.text = drug_list.drugs[indexPath.row]
            
        return cell
        
    }

   
    
}

