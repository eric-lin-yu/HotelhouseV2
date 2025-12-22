//
//  UIViewController+SendEmail.swift
//  just camping
//
//  Created by Eric Lin on 2020/12/31.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import Foundation
import MessageUI

extension UIViewController: MFMailComposeViewControllerDelegate {
    
    public func sendEmail(email: String) {
        let alerts = UIAlertController(title: "", message: "請選擇欲使用的信箱APP", preferredStyle: .actionSheet)
        
        // apple E-mail APP
        let appleBtn = UIAlertAction(title: "Apple 信箱", style: .default) { _ in
            if MFMailComposeViewController.canSendMail() {
                let mailController = MFMailComposeViewController()
                mailController.mailComposeDelegate = self
                mailController.setToRecipients([email])
                self.present(mailController, animated: true, completion: nil)
            } else {
                self.showAlertClosure(title: "通知", message: "您尚未安裝  信箱App", okBtn: "前往下載") {
                    guard let url = URL(string: "https://apps.apple.com/tw/app/id1108187098") else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        alerts.addAction(appleBtn)
        
        // g-mail APP
        // Info內的LSApplicationQueriesSchemes array內，要先新建URL Scheme
        let googleBtn = UIAlertAction(title: "Gmail 信箱", style: .default) { _ in
            // subject: 標題, body： 內容
            let url = URL(string: "googlegmail:///co?subject=Hello&body=Hi&account=\(email)")
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!)
            } else {
                self.showAlertClosure(title: "通知", message: "您尚未安裝 Gmail 信箱App", okBtn: "前往下載") {
                    guard let url = URL(string: "https://apps.apple.com/tw/app/id422689480") else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        alerts.addAction(googleBtn)
        
        let cancelBtn = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        alerts.addAction(cancelBtn)
        self.present(alerts, animated: true, completion: nil)
    }
    
    // apple郵件使用處理狀況
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        #if DEBUG
        print("\n - - - - - - - - - getEmailStatus - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        switch result {
        case .cancelled:
            print("user cancelled")
        case .failed:
            print("user failed")
        case .saved:
            print("user saved email")
        case .sent:
            print("email sent")
        default:
            print("Unknow")
        }
        #endif
        self.dismiss(animated: true, completion: nil)
    }
    
    func goToAppStoreRate() {
        self.showAlertClosure(title: "通知", message: "如果您喜歡此APP，期盼您能給予評分支持，謝謝您", okBtn: "好的") {
            let appID = "1547393444"  //上架後的APP ID
            let appURL = URL(string: "https://itunes.apple.com/us/app/itunes-u/id\(appID)?action=write-review")!
            UIApplication.shared.open(appURL, options: [:],
                                      completionHandler: { (success) in
            })
        }
    }
    
}
