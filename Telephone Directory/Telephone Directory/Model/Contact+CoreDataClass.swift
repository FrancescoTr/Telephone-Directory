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
    
    func updateData(firstName: String, lastName:String, phoneNumber:String) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        CoreDataManager.sharedManager.saveContext()
    }
    
    //Check if the string is a valid phone number in the format specified by the pattern variable
    static func isValidPhoneNumber(string: String) -> Bool {
        let pattern = "^[+][0-9]+[\\s][0-9]+[\\s][0-9]{6,}$"
        var status = false
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let results = regex.numberOfMatches(in: string, options: .anchored, range: NSMakeRange(0, string.count))
            if results > 0 {
                status = true
            }
        } catch let error {
            print(error)
        }
        return status
    }
}
