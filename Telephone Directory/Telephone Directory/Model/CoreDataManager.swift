//
//  CoreDataHelper.swift
//  Telephone Directory
//
//  Created by Francesco Trusiano on 07/07/2018.
//  Copyright © 2018 Francesco Trusiano. All rights reserved.
//

import CoreData
import Foundation

class CoreDataManager {
    
    static let sharedManager = CoreDataManager()
    let containerName = "Contacts"
    
    private init() {}
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Error \(error) - \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    func saveContext() {
        guard managedContext.hasChanges else {return}
        do {
            try managedContext.save()
        } catch let error as NSError {
            //TODO: Manage Save Error
            print("Error saving data: \(error) - \(error.userInfo)")
        }
    }
    
    func loadContacts() throws -> [Contact] {
        do {
            return try self.managedContext.fetch(Contact.fetchRequest())
        } catch  {
            throw error
        }
    }
    
    func saveContact(firstName:String, lastName:String, phoneNumber:String) {
        _ = Contact(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, context: self.managedContext)
        saveContext()
    }
}
