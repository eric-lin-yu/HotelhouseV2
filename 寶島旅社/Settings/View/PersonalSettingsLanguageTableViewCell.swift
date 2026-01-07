//
//  PersonalSettingsLanguageTableViewCell.swift
//  CathayWalletPodTest
//
//  Created by Eric Lin on 2023/3/16.
//

import UIKit

class PersonalSettingsLanguageTableViewCell: UITableViewCell {
    //MARK: - UIs
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .whitesmokeGray
        
        // addsubView
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - setup Constraint
    private func setupConstraint() {
        let topContentViewAnchor = contentView.topAnchor
        let leftContentViewAnchor = contentView.leftAnchor
        let rightContentViewAnchor = contentView.rightAnchor
        let bottomContentViewAnchor = contentView.bottomAnchor
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topContentViewAnchor, constant: 20),
            titleLabel.leftAnchor.constraint(equalTo: leftContentViewAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: bottomContentViewAnchor, constant: -20),
            
            subtitleLabel.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 10),
            subtitleLabel.rightAnchor.constraint(equalTo: rightContentViewAnchor, constant: -20),
            subtitleLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
        ])
    }
    
    func configure(title: String,
                   subtitle: String,
                   tap: UITapGestureRecognizer? = nil) {
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        if let tap {
            subtitleLabel.addGestureRecognizer(tap)
            subtitleLabel.isUserInteractionEnabled = true
            subtitleLabel.textColor = .blue
        }
    }
    
}
