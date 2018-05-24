//
//  InfoViewController2.swift
//  MediScan
//
//  Created by Tony Wu on 5/24/18.
//  Copyright © 2018 Erlun Lian. All rights reserved.
//

import UIKit

class InfoViewController2: UIViewController {

    @IBOutlet weak var drug_name: UILabel!
    @IBOutlet weak var main_usage: UILabel!
    @IBOutlet weak var side_effects: UILabel!
    
    var drug_list = Drugs()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drug_list.set_up_dictionary()
        
        // Use array instead...!
        drug_name.text = array[my_index]
        main_usage.text = drug_list.get_main_usages(name: array[my_index].uppercased())
        side_effects.text = drug_list.get_side_effects(name: array[my_index].uppercased())

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
