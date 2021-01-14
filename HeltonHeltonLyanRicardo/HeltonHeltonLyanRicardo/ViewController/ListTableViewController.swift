//
//  ViewController.swift
//  HeltonHeltonLyanRicardo
//
//  Created by Helton Isac Torres Galindo on 26/12/20.
//

import UIKit

class ListTableViewController: UITableViewController {

    var shoppingList: [ShoppingItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shoppingList.count == 0 {
            self.tableView.setEmptyMessage("Sua lista está vazia!")
        } else {
            self.tableView.restore()
        }
        return shoppingList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let shoppingItem = shoppingList[indexPath.row]
        cell.textLabel?.text = shoppingItem.name
        cell.detailTextLabel?.text = "\(shoppingItem.state)"
        return cell
    }    
}

