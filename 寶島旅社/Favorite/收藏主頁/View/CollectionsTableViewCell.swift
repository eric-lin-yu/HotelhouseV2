//
//  CollectionsTableViewCell.swift
//  寶島旅社
//
//  Created by wistronits on 2023/10/3.
//  Copyright © 2023 Eric Lin. All rights reserved.
//

import UIKit

class CollectionsTableViewCell: UITableViewCell {

    private let spacing: CGFloat = 10
    private let hotelImageViewSize: CGFloat = 140
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // tableView
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraint()
    }
    
    //MARK: - UI
    private let hotelTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .orangeRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isSkeletonable = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let hotelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.isSkeletonable = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let organizationsView: UIView = {
        let view = UIImageView()
        view.addRoundBorder()
        view.isSkeletonable = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let organizationsTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 8)
        label.isSkeletonable = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let organizationsHotelId: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 8)
        label.isSkeletonable = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let organizationsHotelStars: UILabel = {
        let label = UILabel()
        label.textColor = .orangeRed
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13)
        label.isSkeletonable = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bottomButtonView: UIView = {
        let view = UIImageView()
        view.addRoundBorder()
        view.isSkeletonable = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let editBtn: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "pencil")
        button.setImage(image, for: .normal)
        button.tintColor = .orange
        button.isSkeletonable = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let deleteBtn: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "trash")
        button.setImage(image, for: .normal)
        button.tintColor = .orange
        button.isSkeletonable = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        stackView.isSkeletonable = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    //MARK: - setup
    private func setupViews() {
        let viewsToAdd: [UIView] = [
            hotelTitleLabel,
            hotelImageView,
            organizationsView,
            bottomButtonView,
        ]
        viewsToAdd.forEach { contentView.addSubview($0) }
        
        // organizationsView
        let viewsToAddOrganizationsView: [UIView] = [
            organizationsTitle,
            organizationsHotelId,
            organizationsHotelStars,
        ]
        viewsToAddOrganizationsView.forEach { organizationsView.addSubview($0) }
        
        // buttonView
        bottomButtonView.addSubview(buttonStackView)
        
        let viewsToAddButtonStackView: [UIView] = [
            editBtn,
            
            deleteBtn,
        ]
        viewsToAddButtonStackView.forEach { buttonStackView.addArrangedSubview($0) }
    }
    
    private func setupConstraint() {
        let topContentViewAnchor = contentView.topAnchor
        let leftContentViewAnchor = contentView.leftAnchor
        let rightContentViewAnchor = contentView.rightAnchor
        let bottomContentViewAnchor = contentView.bottomAnchor
        
        NSLayoutConstraint.activate([
            hotelImageView.topAnchor.constraint(equalTo: topContentViewAnchor, constant: spacing),
            hotelImageView.rightAnchor.constraint(equalTo: rightContentViewAnchor, constant: -spacing),
            hotelImageView.heightAnchor.constraint(equalToConstant: hotelImageViewSize),
            hotelImageView.widthAnchor.constraint(equalToConstant: hotelImageViewSize),
            
            hotelTitleLabel.leftAnchor.constraint(equalTo: leftContentViewAnchor, constant: spacing),
            hotelTitleLabel.rightAnchor.constraint(equalTo: hotelImageView.leftAnchor, constant: -8),
            
            organizationsView.topAnchor.constraint(equalTo: hotelTitleLabel.bottomAnchor, constant: spacing),
            organizationsView.leftAnchor.constraint(equalTo: hotelTitleLabel.leftAnchor),
            organizationsView.rightAnchor.constraint(equalTo: hotelImageView.leftAnchor, constant: -8),
            organizationsView.bottomAnchor.constraint(equalTo: hotelImageView.bottomAnchor),
            
            organizationsTitle.topAnchor.constraint(equalTo: organizationsView.topAnchor, constant: spacing),
            organizationsTitle.leftAnchor.constraint(equalTo: organizationsView.leftAnchor, constant: spacing),
            organizationsTitle.rightAnchor.constraint(equalTo: organizationsHotelStars.leftAnchor, constant: -8),
            
            organizationsHotelId.topAnchor.constraint(equalTo: organizationsTitle.bottomAnchor, constant: 5),
            organizationsHotelId.leftAnchor.constraint(equalTo: organizationsTitle.leftAnchor),
            organizationsHotelId.rightAnchor.constraint(equalTo: organizationsTitle.rightAnchor),
            organizationsHotelId.bottomAnchor.constraint(equalTo: organizationsView.bottomAnchor, constant: -spacing),
            
            organizationsHotelStars.rightAnchor.constraint(equalTo: organizationsView.rightAnchor, constant: -spacing),
            organizationsHotelStars.centerYAnchor.constraint(equalTo: organizationsView.centerYAnchor),
            
            bottomButtonView.topAnchor.constraint(equalTo: hotelImageView.bottomAnchor, constant: spacing),
            bottomButtonView.leftAnchor.constraint(equalTo: organizationsView.leftAnchor),
            bottomButtonView.rightAnchor.constraint(equalTo: hotelImageView.rightAnchor),
            bottomButtonView.bottomAnchor.constraint(equalTo: bottomContentViewAnchor, constant: -spacing),
            
            buttonStackView.topAnchor.constraint(equalTo: bottomButtonView.topAnchor, constant: spacing),
            buttonStackView.leftAnchor.constraint(equalTo: bottomButtonView.leftAnchor, constant: spacing),
            buttonStackView.rightAnchor.constraint(equalTo: bottomButtonView.rightAnchor, constant: -spacing),
            buttonStackView.bottomAnchor.constraint(equalTo: bottomButtonView.bottomAnchor, constant: -spacing),
        ])
    }
    
    func configure(with hotel: Hotel) {
        hotelTitleLabel.text = hotel.name
        
        hotelImageView.loadUrlImage(urlString: hotel.images.first?.url ?? "") { result in
            switch result {
            case .success(let image):
                if let image = image {
                    self.hotelImageView.image = image
                } else {
                    self.hotelImageView.image = UIImage(named: "iconError")
                }
            case .failure(_):
                self.hotelImageView.image = UIImage(named: "iconError")
            }
        }
        
        // 星级
        organizationsTitle.text = "旅館民宿之管理權責單位代碼"
        organizationsHotelId.text = hotel.id
        
        self.organizationsHotelStars.isHidden = hotel.hotelClass == .unknown
        self.organizationsHotelStars.text = hotel.hotelClass.starDescription
    
        deleteBtn.addTarget(self, action: #selector(deleteDataModelAction), for: .touchUpInside)
        deleteBtn.tag = Int(hotel.id) ?? 0
    }
    
    @objc func deleteDataModelAction(sender: UIButton) {
        let hotelID = sender.tag
        
        if let realm = RealmManager.shard {
            if let hotelToDelete = realm.objects(RLM_CollectionsHotels.self).filter("hotelID == %@", String(hotelID)).first {
                do {
                    try realm.write { realm in
                        realm.delete(hotelToDelete)
                        ResponseHandler.presentAlertHandler(message: "旅店删除成功")
                    }
                } catch {
                    ResponseHandler.errorHandler(errorString: "刪除旅店時發生錯誤")
                }
            } else {
                ResponseHandler.presentAlertHandler(message: "未找到要删除的旅店數據")
            }
        }
    }
}
