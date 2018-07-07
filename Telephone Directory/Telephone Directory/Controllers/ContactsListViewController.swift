//
//  ViewController.swift
//  Telephone Directory
//
//  Created by Francesco Trusiano on 07/07/2018.
//  Copyright © 2018 Francesco Trusiano. All rights reserved.
//

import UIKit

class ContactsListViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contactsTableView:
    UITableView!
    
    
    var contacts = [Contact]()
    var filteredContacts: [Contact]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DetailContactViewController
        switch segue.identifier {
        case "newContactSegue":
            vc.status = .insertingNew
        default:
            return
        }
    }
    
    func refreshData() {
        do {
            try contacts = CoreDataManager.sharedManager.loadContacts()
            filteredContacts = contacts
            contactsTableView.reloadData()
        } catch let error as NSError {
            error.alert(controller: self)
        }
    }
}

//MARK: - TableViewDelegate Methods

extension ContactsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCellID", for: indexPath) as! ContactsTableViewCell
        let contact = filteredContacts[indexPath.row]
        cell.setNameLabel(firstName: contact.firstName!, lastName: contact.lastName!)
        cell.setPhoneLabel(phoneNumber: contact.phoneNumber!)
        return cell
    }
}

//MARK: - SearchBarDelegate Methods

extension ContactsListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchTextLowerCase = searchText.lowercased()
        filteredContacts = searchText.isEmpty ? contacts : contacts.filter({ (contact) -> Bool in
            return (contact.firstName?.lowercased().contains(searchTextLowerCase))! || (contact.lastName?.lowercased().contains(searchTextLowerCase))! || (contact.phoneNumber?.lowercased().contains(searchTextLowerCase))!
        })
        contactsTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel button clicked")
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
