//
//  ViewController.swift
//  Telephone Directory
//
//  Created by Francesco Trusiano on 07/07/2018.
//  Copyright © 2018 Francesco Trusiano. All rights reserved.
//

import UIKit

class ContactsListViewController: UIViewController {

    @IBOutlet weak var contactsTableView: UITableView!
    var contacts = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    func refreshData() {
        do {
            try contacts = CoreDataManager.sharedManager.loadContacts()
            contactsTableView.reloadData()
        } catch let error as NSError {
            error.alert(controller: self)
        }
    }
}

extension ContactsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCellID", for: indexPath) as! ContactsTableViewCell
        let contact = contacts[indexPath.row]
        cell.setNameLabel(firstName: contact.firstName!, lastName: contact.lastName!)
        cell.setPhoneLabel(phoneNumber: contact.phoneNumber!)
        return cell
    }
}
