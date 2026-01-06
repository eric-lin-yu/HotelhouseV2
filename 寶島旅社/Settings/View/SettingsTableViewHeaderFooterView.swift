//
//  UITableViewHeaderFooterView.swift
//  CathayWalletPodTest
//
//  Created by Eric Lin on 2023/4/28.
//

import UIKit

class SettingsTableViewHeaderFooterView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "MySectionHeaderView"
    static let height: CGFloat = 50
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(title: String?, reuseIdentifier: String?, bgColor: UIColor? = nil) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = bgColor ?? .white
        self.contentView.layer.cornerRadius = 20
        self.contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        self.titleLabel.text = title
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.sageGreen
        return label
    }()
}

