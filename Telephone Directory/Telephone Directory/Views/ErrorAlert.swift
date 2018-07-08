//
//  ErrorAlert.swift
//  Telephone Directory
//
//  Created by Francesco Trusiano on 07/07/2018.
//  Copyright © 2018 Francesco Trusiano. All rights reserved.
//

import UIKit

extension NSError {
    func alert(controller: UIViewController?) {
        let alertController = UIAlertController(title: "Error", message: self.description, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(action)
        let presentingController = controller ?? UIApplication.topViewController()
        guard presentingController != nil else {
            print("Error: \(self.description)")
            return
        }
        presentingController?.present(alertController, animated: true, completion: nil)
    }
}
