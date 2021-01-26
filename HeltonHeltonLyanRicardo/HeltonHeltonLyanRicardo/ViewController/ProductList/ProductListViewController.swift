//
//  ViewController.swift
//  HeltonHeltonLyanRicardo
//
//  Created by Helton Isac Torres Galindo on 26/12/20.
//

import UIKit
import CoreData

class ProductListViewController: UITableViewController {

    var products: [Product] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchProducts()
    }
    
    private func fetchProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
        do {
            products = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if products.count == 0 {
            self.tableView.setEmptyMessage("Sua lista está vazia!")
        } else {
            self.tableView.restore()
        }
        return products.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Product", for: indexPath) as? ProductTableViewCell else {
            return UITableViewCell()
        }
        
        let product = products[indexPath.row]
        
        if let imageData = product.photo {
            cell.productImageView?.image = UIImage(data: imageData)
        } else {
            cell.productImageView?.image = UIImage(named: "bag.fill.badge.plus")
        }
        cell.productNameLabel?.text = product.name
        
        if let price = product.price{
            cell.productPriceLabel?.text = "\(price)"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            
            let product = self.products[indexPath.row]
            context.delete(product)
            
            do {
                try context.save()
                self.products.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
}

