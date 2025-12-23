//
//  ImageCollectionViewCell.swift
//  寶島旅社
//
//  Created by Eric Lin on 2022/10/20.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit

class HotelImageCollectionViewCell: UICollectionViewCell {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubView()
        setupConstraint()
    }
    
    //MARK: - UI
    private let hotelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .orangeRed
        label.font = .boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        label.numberOfLines = 0
        
        //圓角
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        
        //邊框線條
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.sageGreen.cgColor
        
        label.backgroundColor = .white
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let popupView: UIView = {
        let view = UIView()
        view.addRoundBorder()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let popupTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.textAlignment = .center
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "iconClosed(R)")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - setup
    private func setupSubView() {
        let viewsToAdd: [UIView] = [
            hotelImageView,
            titleLabel,
            popupView,
        ]
        viewsToAdd.forEach { contentView.addSubview($0) }
        
        let viewsToAddPopupView: [UIView] = [
            popupTextView,
            closeButton,
        ]
        viewsToAddPopupView.forEach { popupView.addSubview($0) }
        popupView.isHidden = true
    }
    
    private func setupConstraint() {
        let topContentViewAnchor = contentView.topAnchor
        let leftContentViewAnchor = contentView.leftAnchor
        let rightContentViewAnchor = contentView.rightAnchor
        let bottomContentViewAnchor = contentView.bottomAnchor
        
        NSLayoutConstraint.activate([
            hotelImageView.topAnchor.constraint(equalTo: topContentViewAnchor),
            hotelImageView.leftAnchor.constraint(equalTo: leftContentViewAnchor),
            hotelImageView.rightAnchor.constraint(equalTo: rightContentViewAnchor),
            hotelImageView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: hotelImageView.bottomAnchor, constant: 10),
            titleLabel.leftAnchor.constraint(equalTo: hotelImageView.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: hotelImageView.rightAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomContentViewAnchor),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            
            popupView.topAnchor.constraint(equalTo: topContentViewAnchor, constant: 10),
            popupView.leftAnchor.constraint(equalTo: leftContentViewAnchor, constant: 10),
            popupView.rightAnchor.constraint(equalTo: rightContentViewAnchor, constant: -10),
            popupView.bottomAnchor.constraint(equalTo: bottomContentViewAnchor, constant: -10),
            
            popupView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            popupView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            popupView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            
            popupTextView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 10),
            popupTextView.leftAnchor.constraint(equalTo: popupView.leftAnchor, constant: 10),
            popupTextView.rightAnchor.constraint(equalTo: popupView.rightAnchor, constant: -10),
            popupTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150),
            
            closeButton.topAnchor.constraint(equalTo: popupTextView.bottomAnchor, constant: 10),
            closeButton.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: popupView.bottomAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 25),
            closeButton.heightAnchor.constraint(equalToConstant: 25),
        ])
    }
    
    func configure(with model: HotelImage?) {
        let errorImage = GifImageNames.shared.errorImageName
        popupView.isHidden = true
        
        guard let model = model else {
            hotelImageView.loadGif(name: errorImage)
            titleLabel.text = "很抱歉，此旅店尚未提供圖檔哦~"
            return
        }
        
        // 載入圖片
        self.hotelImageView.loadUrlImage(urlString: model.url) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self?.hotelImageView.image = image ?? UIImage(named: errorImage)
                case .failure:
                    self?.hotelImageView.loadGif(name: errorImage)
                }
            }
        }
        
        // 設定文字
        let description = model.description.isEmpty ? "實景示意圖" : model.description
        titleLabel.text = description
        popupTextView.text = description
    }
    
    @objc private func togglePopup() {
        // 只有當文字長度超過一定限制才顯示彈窗 (例如 18 字)
        if let text = titleLabel.text, text.count > 18 {
            popupView.isHidden.toggle()
        }
    }
    
    @objc func handleTitleLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let titleLabelText = titleLabel.text, titleLabelText.count > 18 else {
            return
        }
        popupView.isHidden = false
        popupTextView.text = titleLabelText
        closeButton.addTarget(self, action: #selector(closePopup(_:)), for: .touchUpInside)
    }
    
    @objc func closePopup(_ sender: UIButton) {
        popupView.isHidden = true
    }
}
