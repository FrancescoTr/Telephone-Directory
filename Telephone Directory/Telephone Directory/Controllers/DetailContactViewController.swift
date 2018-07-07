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
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        phoneTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViews()
    }
    
    func configureViews() {
        switch status {
        case .insertingNew:
            buttonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(DetailContactViewController.saveContact))
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
}

//MARK: - TextFieldDelegate Methods

extension DetailContactViewController:UITextFieldDelegate {
    
}
