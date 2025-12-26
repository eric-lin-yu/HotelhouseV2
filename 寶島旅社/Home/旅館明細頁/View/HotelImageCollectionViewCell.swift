//
//  ImageCollectionViewCell.swift
//  寶島旅社
//
//  Created by Eric Lin on 2022/10/20.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit

class HotelImageCollectionViewCell: UICollectionViewCell {
    //MARK: - UI
    private let hotelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // 浮動標籤樣式
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 半透明背景
        label.textAlignment = .center
        label.numberOfLines = 1
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupSubView()
        self.setupConstraint()
        self.setupGestures()
    }
    
    //MARK: - setup
    private func setupSubView() {
        // 先放底層圖片
        contentView.addSubview(hotelImageView)
        // 標籤放在圖片上
        contentView.addSubview(titleLabel)
        // 彈窗放在最頂層
        contentView.addSubview(popupView)
        
        self.popupView.addSubview(popupTextView)
        self.popupView.addSubview(closeButton)
        
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        self.popupView.isHidden = true
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            // 圖片填滿整個 Cell
            self.hotelImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.hotelImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            self.hotelImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            self.hotelImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // 標籤貼在圖片底部
            self.titleLabel.leftAnchor.constraint(equalTo: hotelImageView.leftAnchor),
            self.titleLabel.rightAnchor.constraint(equalTo: hotelImageView.rightAnchor),
            self.titleLabel.bottomAnchor.constraint(equalTo: hotelImageView.bottomAnchor),
            self.titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            // popupView：設定為填滿整個 contentView，作為一個浮層
            self.popupView.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.popupView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.popupView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            self.popupView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // popupTextView：在 popupView 內部置中
            self.popupTextView.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            self.popupTextView.centerYAnchor.constraint(equalTo: popupView.centerYAnchor, constant: -15),
            self.popupTextView.widthAnchor.constraint(equalTo: popupView.widthAnchor, multiplier: 0.8),
            self.popupTextView.heightAnchor.constraint(equalToConstant: 120),
            
            // closeButton：放在文字框右上方或正下方
            self.closeButton.topAnchor.constraint(equalTo: popupTextView.bottomAnchor, constant: 8),
            self.closeButton.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            self.closeButton.widthAnchor.constraint(equalToConstant: 30),
            self.closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupGestures() {
        // 確保 titleLabel 可以互動
        self.titleLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTitleLabelTap(_:)))
        self.titleLabel.addGestureRecognizer(tap)
        
        // 關閉按鈕事件
        self.closeButton.addTarget(self, action: #selector(closePopup(_:)), for: .touchUpInside)
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
                    let targetImage = image ?? UIImage(named: errorImage)
                    self?.hotelImageView.setImageWithFade(targetImage)
                case .failure:
                    self?.hotelImageView.loadGif(name: errorImage)
                }
            }
        }
        
        let description = model.description.isEmpty ? "實景示意圖" : model.description
        self.titleLabel.text = description.count > 18 ? " \(description.prefix(17))..." : " \(description)"
        self.popupTextView.text = description
        self.popupView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
    }
    
    /// 點擊事件
    @objc func handleTitleLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let fullText = popupTextView.text, fullText.count > 18 else { return }
        
        // 將 popupView 提到最前方並顯示
        contentView.bringSubviewToFront(popupView)
        self.popupView.alpha = 0
        self.popupView.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.popupView.alpha = 1
        }
    }
    
    @objc func closePopup(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            self.popupView.alpha = 0
        }) { _ in
            self.popupView.isHidden = true
        }
    }
}
