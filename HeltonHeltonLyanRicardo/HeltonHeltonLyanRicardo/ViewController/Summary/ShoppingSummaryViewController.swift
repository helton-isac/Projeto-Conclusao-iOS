//
//  ShoppingSummaryViewController.swift
//  HeltonHeltonLyanRicardo
//
//  Created by Helton Isac Torres Galindo on 21/01/21.
//

import UIKit
import CoreData

class ShoppingSummaryViewController: UIViewController {

    @IBOutlet var dollarTotalLabel: UILabel!
    @IBOutlet var realTotalLabel: UILabel!
    
    var products: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getTotals()
    }
    
    private func getTotals() {
        let defaults = UserDefaults.standard
        var quotation: Decimal = 1
        var financialTax: Decimal = 1
        if let strQuotation = defaults.string(forKey: "quotation") {
            quotation = Decimal(string: strQuotation) ?? 1
        }
        if let strFinancialTax = defaults.string(forKey: "financial_tax") {
            financialTax = Decimal(string: strFinancialTax) ?? 1
        }
        
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
        do {
            products = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        var dollarTotal: Decimal = 0;
        var realTotal: Decimal = 0;
        
        for product in products {
            if let price = product.price {
                dollarTotal = price as Decimal + dollarTotal
                let realPrice = price as Decimal * quotation
                
                var financialTaxTotal: Decimal = 0
                if (product.creditCard) {
                    financialTaxTotal = realPrice * financialTax / 100
                }
                
                let stateTax = (product.state?.tax ?? 1) as Decimal
                let stateTaxTotal = realPrice * stateTax / 100
                let productRealTotalPrice = realPrice + financialTaxTotal + stateTaxTotal
                realTotal = productRealTotalPrice + realTotal
            }
        }
        dollarTotalLabel.text = "\(dollarTotal)"
        realTotalLabel.text = "\(realTotal)"
    }
}
