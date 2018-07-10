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
        //Configure the viewController according to the kind of action required
        switch status {
        case .insertingNew:
            buttonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(DetailContactViewController.saveContact))
            buttonItem.isEnabled = false
            importContactButton.isHidden = false
            //Check if the content of the textfields is a valid data entry
            for textField in textFields {
                textFieldEdited(textField)
            }
        case .editing:
            buttonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(DetailContactViewController.saveContact))
            for textField in textFields {
                textField.isUserInteractionEnabled = true
                textFieldEdited(textField)
            }
            firstNameTextField.becomeFirstResponder()
        case .displaying:
            buttonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(DetailContactViewController.editContact))
            firstNameTextField.text = contact?.firstName
            lastNameTextField.text = contact?.lastName
            phoneTextField.text = contact?.phoneNumber
            for textField in textFields {
                textField.isUserInteractionEnabled = false
            }
        default:
            return
        }
        self.navigationItem.rightBarButtonItem = buttonItem
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
        //Does not allow the data in the textfields to start with a space
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        textField.layer.borderWidth = 1
        //Change the color of the texfields' border according to the data validity
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
        //Enable the Save button if the data is valid
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
        //The phone number thextfield only allows the right character (+, number, space) to be inserted
        guard textField == phoneTextField else {
                return true
        }
        //Backspace
        guard !string.isEmpty else { return true }
        //First character must be "+"
        if let text = textField.text, let textRange = Range(range, in: text) {
            guard let lastChar = text[text.startIndex..<textRange.lowerBound].last else {
                return string == "+"
            }
            var allowedCharacters = CharacterSet.decimalDigits
            switch lastChar {
            //After the "+" or a space, the only allowed charaters are number digits
            case "+":
                return string.rangeOfCharacter(from: allowedCharacters) != nil
            case " ":
                return string.rangeOfCharacter(from: allowedCharacters) != nil
            //After a digit, a space is allowed only if there are less than two spaces in the phone textfield
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
        //Remove all characters beside digits, plus sign and spaces from the imported phone number
        let filteredPhone = String(phone.unicodeScalars.filter { allowedCharacters.contains($0) })
        //Insert "+39" if there is not already a "+" in the imported phone number
        if filteredPhone.contains("+") {
            self.phoneTextField.text = filteredPhone
        } else {
            self.phoneTextField.text = "+39 " + filteredPhone
        }
    }
}

