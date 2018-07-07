//
//  InsertContactViewController.swift
//  Telephone Directory
//
//  Created by Francesco Trusiano on 07/07/2018.
//  Copyright © 2018 Francesco Trusiano. All rights reserved.
//

import UIKit
import ContactsUI

enum Status {
    case editing
    case displaying
    case insertingNew
}

class DetailContactViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var importContactButton: UIButton!
    
    var buttonItem: UIBarButtonItem!
    var status: Status!
    var contact: Contact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
    func configureTextFields() {
        firstNameTextField.delegate = self
        firstNameTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        lastNameTextField.delegate = self
        lastNameTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        phoneTextField.delegate = self
        phoneTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
    }
    
    func configureView() {
        switch status {
        case .insertingNew:
            buttonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(DetailContactViewController.saveContact))
            buttonItem.isEnabled = false
            self.navigationItem.rightBarButtonItem = buttonItem
            importContactButton.isHidden = false
        case .editing:
            buttonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(DetailContactViewController.saveContact))
            self.navigationItem.rightBarButtonItem = buttonItem
            firstNameTextField.isUserInteractionEnabled = true
            lastNameTextField.isUserInteractionEnabled = true
            phoneTextField.isUserInteractionEnabled = true
            firstNameTextField.becomeFirstResponder()
        case .displaying:
            buttonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(DetailContactViewController.editContact))
            self.navigationItem.rightBarButtonItem = buttonItem
            firstNameTextField.text = contact?.firstName
            lastNameTextField.text = contact?.lastName
            phoneTextField.text = contact?.phoneNumber
            firstNameTextField.isUserInteractionEnabled = false
            lastNameTextField.isUserInteractionEnabled = false
            phoneTextField.isUserInteractionEnabled = false
        default:
            return
        }
    }
    
    @objc func saveContact() {
        switch status {
        case .insertingNew:
            CoreDataManager.sharedManager.saveContact(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, phoneNumber: phoneTextField.text!)
        case .editing:
            guard let contact = contact else {break}
            contact.updateData(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, phoneNumber: phoneTextField.text!)
        default:
            break
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc func editContact() {
        status = .editing
        configureView()
    }
    
    @IBAction func importContact(_ sender: Any) {
        let contactController = CNContactPickerViewController()
        contactController.delegate = self
        self.present(contactController, animated: true, completion: nil)
    }
    
    @objc func textFieldEdited(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
        let firstName = firstNameTextField.text, !firstName.isEmpty,
        let lastName = lastNameTextField.text, !lastName.isEmpty,
        let phone = phoneTextField.text, Contact.isValidPhoneNumber(string: phone)
        else {
            buttonItem.isEnabled = false
            return
        }
        buttonItem.isEnabled = true
    }
}

//MARK: - TextFieldDelegate Methods

extension DetailContactViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField === phoneTextField else {return true}
        return true
    }
    
}

//MARK: - ContactPickerDelegate Methods

extension DetailContactViewController:CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let firstName = contact.givenName
        let lastName = contact.familyName
        let phone = contact.phoneNumbers.first?.value.stringValue
        self.firstNameTextField.text = firstName
        self.lastNameTextField.text = lastName
        self.phoneTextField.text = phone
    }
}

