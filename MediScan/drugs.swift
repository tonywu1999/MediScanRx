//
//  drugs.swift
//  MediScan
//
//  Created by Tony Wu on 4/14/18.
//  Copyright © 2018 Erlun Lian. All rights reserved.
//

import Foundation


class Drugs {
    
    var drug_list: [String:Int]
    var side_effects: [String]
    var main_usages: [String]
    var drugs: [String]
    
    init() {
        drug_list = [String: Int]()
        side_effects = [String]()
        main_usages = [String]()
        drugs = [String]()
        
        let text = read()
        let lines: [String] = text.components(separatedBy: "\n")
        var count: Int = 0
        for drug in lines {
            var categories: [String] = drug.components(separatedBy: "\t")
            if(categories[0] == "Drug Name") {
                break;
            }
            // Ensures no duplicate drugs are placed into database. Makes creation of drugs class really slow!
            // I ensured no duplicates in a python script that extracted drug data from rxlist.com
            // if(!(drugs.contains(categories[0]))) {
            // }
            drug_list[categories[0].uppercased()] = count
            drugs.append(categories[0])
            side_effects.append(categories[1])
            main_usages.append(categories[2])
            count = count + 1
        }
    }
    
    func read() -> String {
        let path = Bundle.main.path(forResource: "database", ofType: "txt")
        print(path!)
        
        let url = URL(fileURLWithPath: path!)
        print(url)
        
        let contentString = try! NSString(contentsOf: url, encoding: String.Encoding.utf8.rawValue) as String
        return contentString
        
    }
    func get_side_effects(name: String) -> String {
        return side_effects[drug_list[name]!]
    }
    func get_main_usages(name: String) -> String {
        return main_usages[drug_list[name]!]
    }
    func drug_in_database(name: String) -> Bool {
        for (key, value) in drug_list {
            if (name == key) {
                return true
            }
        }
        return false
    }
}
