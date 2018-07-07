//
//  Contact+CoreDataProperties.swift
//  Telephone Directory
//
//  Created by Francesco Trusiano on 07/07/2018.
//  Copyright © 2018 Francesco Trusiano. All rights reserved.
//
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var phoneNumber: String?

}
