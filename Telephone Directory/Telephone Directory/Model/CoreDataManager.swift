//
//  CoreDataHelper.swift
//  Telephone Directory
//
//  Created by Francesco Trusiano on 07/07/2018.
//  Copyright © 2018 Francesco Trusiano. All rights reserved.
//

import CoreData
import Foundation

//Singleton to manage the CoreData stack, load contacts and save them

class CoreDataManager {
    
    static let sharedManager = CoreDataManager()
    let containerName = "Contacts"
    
    private init() {}
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                error.alert(controller: nil)
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
            error.alert(controller: nil)
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
