//
//  FavoritesViewController.swift
//  MediScan
//
//  Created by Tony Wu on 5/18/18.
//  Copyright © 2018 Erlun Lian. All rights reserved.
//

import UIKit

var array = [String]()

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var drug_list = Drugs()
    
    // Put this somewhere else
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        drug_list.set_up_dictionary()
        
        array = UserDefaults.standard.stringArray(forKey: "SavedStringArray") ?? [String]()
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns number of rows
        if UserDefaults.standard.object(forKey: "SavedStringArray") != nil {
            // Also should check if we already favorited the drug
            return array.count
        }
        else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create a UI Table View for each drug
        
        if array.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FcustomCell") as! CustomTableViewCell
            cell.fdrug_label.text = array[indexPath.row]
            return cell
        }
        else {
            let cell = UITableViewCell()
            return cell
        }
    }
    
    // Function for selection of a row to information viewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        my_index = indexPath.row
        performSegue(withIdentifier: "favorite_segue", sender: self)
        
    }

}
