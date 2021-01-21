//
//  NewProductViewController.swift
//  HeltonHeltonLyanRicardo
//
//  Created by Lyan Masterson on 21/01/21.
//

import UIKit
import CoreData

class NewProductViewController: UIViewController {

    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var stateNameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    
    @IBOutlet weak var creditCardSwitch: UISwitch!
    @IBOutlet weak var productImageView: UIImageView!
    
    private var states: [NSManagedObject] = [] {
        didSet {
            statePicker.reloadAllComponents()
        }
    }
    
    private var selectedState: NSManagedObject?
    
    private var image: UIImage? {
        didSet {
            self.productImageView.image = image
            self.productImageView.setNeedsDisplay()
        }
    }
    
    private let statePicker = ToolbarPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.changeProductPicture))
        self.productImageView.addGestureRecognizer(tap)
        
        self.stateNameTextField.inputView = statePicker
        self.stateNameTextField.inputAccessoryView = statePicker.toolbar
        
        self.statePicker.delegate = self
        self.statePicker.dataSource = self
        self.statePicker.toolbarDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchStates()
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
    
    @objc private func changeProductPicture() {
        let action = UIAlertController(title: "Selecionar poster",
                                       message: "De onde você quer escolher o poster",
                                       preferredStyle: .actionSheet)
        
        let photoLibrary = UIAlertAction(title: "Biblioteca de fotos", style: .default) { _ in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        }
        
        let camera = UIAlertAction(title: "Câmera", style: .default) { _ in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        }
        
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel)
        
        action.addAction(photoLibrary)
        action.addAction(camera)
        action.addAction(cancel)
        
        self.present(action, animated: true, completion: nil)
    }
    
    @IBAction func submitNewProduct(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Product", in: context) else { return }
        let product = NSManagedObject(entity: entity, insertInto: context)
        
        let isCreditCard = creditCardSwitch.isOn
        let price = Decimal(string: priceTextField.text ?? "0")
        let name = productNameTextField.text
        let imageData = image?.pngData() ?? productImageView.image?.pngData()
        
        product.setValue(isCreditCard, forKeyPath: "creditCard")
        product.setValue(price, forKeyPath: "value")
        product.setValue(name, forKeyPath: "name")
        product.setValue(imageData, forKeyPath: "photo")
        
        do {
            try context.save()
            navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

extension NewProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let presentedController = self.presentedViewController, presentedController is UIImagePickerController {
            presentedController.dismiss(animated: true, completion: nil)
        }
    
        guard let image = info[.editedImage] as? UIImage else {
            print("Imagem não encontrada")
            return
        }
        
        self.image = image
    }
    
}

extension NewProductViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states[row].value(forKeyPath: "name") as? String
    }
}

extension NewProductViewController: ToolbarPickerViewDelegate {
    func didTapDone(tag: Int) {
        let row = statePicker.selectedRow(inComponent: 0)
        statePicker.selectRow(row, inComponent: 0, animated: false)
        if states.count - 1 >= row {
            stateNameTextField.text = states[row].value(forKeyPath: "name") as? String
        }
        
        selectedState = states[row]
        
        self.view.endEditing(true)
    }
    
    func didTapCancel(tag: Int) {
        stateNameTextField.text = selectedState?.value(forKeyPath: "name") as? String
        
        self.view.endEditing(true)
    }
}

