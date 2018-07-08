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
    
    @IBOutlet var textFields: [UITextField]!
    
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
        for textField in textFields {
            textField.delegate = self
            textField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        }
    }
    
    func configureView() {
        switch status {
        case .insertingNew:
            buttonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(DetailContactViewController.saveContact))
            buttonItem.isEnabled = false
            self.navigationItem.rightBarButtonItem = buttonItem
            importContactButton.isHidden = false
            for textField in textFields {
                textFieldEdited(textField)
            }
        case .editing:
            buttonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(DetailContactViewController.saveContact))
            self.navigationItem.rightBarButtonItem = buttonItem
            for textField in textFields {
                textField.isUserInteractionEnabled = true
            }
            firstNameTextField.becomeFirstResponder()
        case .displaying:
            buttonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(DetailContactViewController.editContact))
            self.navigationItem.rightBarButtonItem = buttonItem
            firstNameTextField.text = contact?.firstName
            lastNameTextField.text = contact?.lastName
            phoneTextField.text = contact?.phoneNumber
            for textField in textFields {
                textField.isUserInteractionEnabled = false
            }
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
        textField.layer.borderWidth = 1
        if textField != phoneTextField {
            switch textField.text!.isEmpty {
            case false:
                textField.layer.borderColor = UIColor.green.cgColor
            default:
                textField.layer.borderColor = UIColor.red.cgColor
            }
        } else {
            switch Contact.isValidPhoneNumber(string: textField.text!) {
            case true:
                textField.layer.borderColor = UIColor.green.cgColor
            default:
                textField.layer.borderColor = UIColor.red.cgColor
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
        guard textField == phoneTextField else {
                return true
        }
        guard !string.isEmpty else {return true}
        if let text = textField.text, let textRange = Range(range, in: text) {
            guard let lastChar = text[text.startIndex..<textRange.lowerBound].last else {
                return string == "+"
            }
            var allowedCharacters = CharacterSet.decimalDigits
            switch lastChar {
            case "+":
                return string.rangeOfCharacter(from: allowedCharacters) != nil
            case " ":
                return string.rangeOfCharacter(from: allowedCharacters) != nil
            default:
                if (textField.text?.components(separatedBy: " ").count)! < 3 {
                    allowedCharacters.insert(charactersIn: " ")
                    return string.rangeOfCharacter(from: allowedCharacters) != nil
                } else {
                    return string.rangeOfCharacter(from: allowedCharacters) != nil
                }
            }
        }
        return false
    }
}

//MARK: - ContactPickerDelegate Methods

extension DetailContactViewController:CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let firstName = contact.givenName
        let lastName = contact.familyName
        let phone = contact.phoneNumbers.first?.value.stringValue ?? ""
        self.firstNameTextField.text = firstName
        self.lastNameTextField.text = lastName
        var allowedCharacters = CharacterSet.decimalDigits
        allowedCharacters.insert(charactersIn: "+")
        allowedCharacters.insert(Unicode.Scalar(160))
        allowedCharacters.insert(Unicode.Scalar(32))
        let filteredPhone = String(phone.unicodeScalars.filter { allowedCharacters.contains($0) })
        if filteredPhone.contains("+") {
            self.phoneTextField.text = filteredPhone
        } else {
            self.phoneTextField.text = "+39 " + filteredPhone
        }
        _  = textField(phoneTextField, shouldChangeCharactersIn: NSRange.init(), replacementString: "")
    }
}

