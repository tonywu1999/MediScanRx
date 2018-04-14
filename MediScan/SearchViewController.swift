//
//  SearchViewController.swift
//  MediScan
//
//  Created by Tony Wu on 4/14/18.
//  Copyright © 2018 Erlun Lian. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var drug_name: UITextField!
    @IBOutlet weak var result: UILabel!
    var drug_list = Drugs()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.drug_name.delegate = self
        drug_list.set_up_dictionary()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func side_effects(_ sender: UIButton) {
        let user_input: String = drug_name.text!
        if(drug_list.drug_in_database(name: user_input.uppercased())) {
            let title2 = drug_list.get_side_effects(name: user_input.uppercased())
            result.text = title2
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return (true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
