//
//  SKHBaseViewController.swift
//  Pitaya
//
//  Created by Joy Lee on 2019/6/25.
//  Copyright © 2019 Joy Lee. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var activeField : UITextField?
    var tap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWasShown(notification: Notification) {
        let info = notification.userInfo!
        let keyboardSize = (info["UIKeyboardFrameBeginUserInfoKey"] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets
        if #available(iOS 11.0, *) {
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height - self.view.safeAreaInsets.bottom, right: 0.0)
        } else {
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        }
    
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = tableView.contentInset//contentInsets

        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if activeField != nil {
            if (!aRect.contains(self.activeField!.frame.origin )){
                tableView.scrollRectToVisible(self.activeField!.frame, animated: true)
             }
        }
    }

    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInsets : UIEdgeInsets = .zero
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
  

}

// MARK: extension ViewController Library
extension UIViewController {
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showAlertClosure(title: String, message: String, okBtn: String, handler: (()->())?) {
        let alerts = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: okBtn, style: .default) { _ in
            if handler != nil {
                handler!()
            }
        }
        let cancelBtn = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        alerts.addAction(cancelBtn)
        alerts.addAction(okBtn)
        
        self.present(alerts, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelBtn = UIAlertAction(title: "關閉", style: .default, handler: nil)
        alertController.addAction(cancelBtn)
        self.present(alertController, animated: true, completion: nil)
    }
}
