//
//  Contact+CoreDataClass.swift
//  Telephone Directory
//
//  Created by Francesco Trusiano on 07/07/2018.
//  Copyright © 2018 Francesco Trusiano. All rights reserved.
//
//

import Foundation
import CoreData


public class Contact: NSManagedObject {
    convenience init(firstName: String, lastName:String, phoneNumber:String, context: NSManagedObjectContext) {
        let entity = Contact.entity()
        self.init(entity: entity, insertInto: context)
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
    }
}
