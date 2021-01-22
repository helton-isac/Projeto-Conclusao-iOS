//
//  SettingsViewController.swift
//  HeltonHeltonLyanRicardo
//
//  Created by Lyan Masterson on 18/01/21.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var quotationTextField: UITextField!
    @IBOutlet weak var financialTaxTextField: UITextField!
    
    @IBOutlet weak var statesTableView: UITableView!
    
    var states: [NSManagedObject] = [] {
        didSet {
            DispatchQueue.main.async {
                self.statesTableView.reloadData()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.statesTableView.delegate = self
        self.statesTableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.defaultsChanged),
                                               name: UserDefaults.didChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchStates()
        
        UserDefaults.standard.synchronize()
        self.updateScreenFields()
    }

    @objc func defaultsChanged() {
        self.updateScreenFields()
    }
    
    private func updateScreenFields() {
        let defaults = UserDefaults.standard
        self.quotationTextField.text = defaults.string(forKey: "quotation")
        self.financialTaxTextField.text = defaults.string(forKey: "financial_tax")
        
        self.statesTableView.reloadData()
    }
    
    private func fetchStates() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "State")
        
        do {
            self.states = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func addState(_ sender: Any) {
        let alertController = UIAlertController(title: "Adicionar Estado", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Nome do estado"
        }
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Imposto"
        }
        
        let saveAction = UIAlertAction(title: "Adicionar", style: .default, handler: { alert -> Void in
            guard let fields = alertController.textFields, fields.count > 1 else { return }
            
            let state = fields[0].text ?? ""
            let tax = Double(fields[1].text ?? "0") ?? 0.0
            
            self.saveNewState(name: state, tax: tax)
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func saveNewState(name: String, tax: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "State", in: context) else { return }
        let state = NSManagedObject(entity: entity, insertInto: context)
        
        state.setValue(name, forKeyPath: "name")
        state.setValue(tax, forKeyPath: "tax")
        
        do {
            try context.save()
            self.states.append(state)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        states.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "State", for: indexPath) as? StateTableViewCell else {
            return UITableViewCell()
        }
        
        let state = states[indexPath.row]
        
        cell.stateTextField?.text = state.value(forKeyPath: "name") as? String
        cell.taxTextField?.text = String(state.value(forKeyPath: "tax") as? Double ?? 0.0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            
            let state = self.states[indexPath.row]
            context.delete(state)
            
            do {
                try context.save()
                self.states.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
}
