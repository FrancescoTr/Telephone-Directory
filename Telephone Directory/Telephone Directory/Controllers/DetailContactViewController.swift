//
//  InsertContactViewController.swift
//  Telephone Directory
//
//  Created by Francesco Trusiano on 07/07/2018.
//  Copyright © 2018 Francesco Trusiano. All rights reserved.
//

import UIKit

enum Status {
    case editing
    case displaying
    case insertingNew
}

class DetailContactViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    var buttonItem: UIBarButtonItem!
    var status: Status!
    
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
        case .editing:
            return
        case .displaying:
            return
        default:
            return
        }
    }
    
    @objc func saveContact() {
        CoreDataManager.sharedManager.saveContact(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, phoneNumber: phoneTextField.text!)
        navigationController?.popViewController(animated: true)
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
        return true
    }
    
}

//MARK: - Toggle UIBarButtonItem Extension

