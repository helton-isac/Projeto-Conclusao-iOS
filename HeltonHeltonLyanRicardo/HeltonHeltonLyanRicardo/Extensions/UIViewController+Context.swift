//
//  UIViewController+Context.swift
//  HeltonHeltonLyanRicardo
//
//  Created by Helton souza silveira on 25/01/21.
//

import UIKit
import CoreData

extension UIViewController {
    var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}
