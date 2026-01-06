//
//  PersonalSettingsTableViewCell.swift
//  CathayWalletPodTest
//
//  Created by Eric Lin on 2023/3/15.
//

import UIKit

class PersonalSettingsIconTableViewCell: UITableViewCell {
    //MARK: - UI
    private let titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowRightImageView: UIImageView = {
        let imageView = UIImageView()
        
        let image = UIImage(named: "btnArrowRight(B)")
        imageView.image = image
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none

        // addsubView
        addSubview(titleImageView)
        addSubview(titleNameLabel)
        addSubview(arrowRightImageView)
        
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - setup Constraint
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            titleImageView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            titleImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            titleImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            titleImageView.widthAnchor.constraint(equalToConstant: 36),
            
            titleNameLabel.leftAnchor.constraint(equalTo: titleImageView.rightAnchor, constant: 10),
            titleNameLabel.centerYAnchor.constraint(equalTo: titleImageView.centerYAnchor),
            
            arrowRightImageView.heightAnchor.constraint(equalToConstant: 24),
            arrowRightImageView.widthAnchor.constraint(equalToConstant: 24),
            
            arrowRightImageView.leftAnchor.constraint(equalTo: titleNameLabel.rightAnchor, constant: 10),
            arrowRightImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            arrowRightImageView.centerYAnchor.constraint(equalTo: titleImageView.centerYAnchor),
        ])
    }

    func configure(image: String, title: String) {
        
        titleImageView.image = UIImage(named: image)
        titleNameLabel.text = title

    }
}
