//
//  FrontPageTableViewCell.swift
//  寶島旅社
//
//  Created by Eric Lin on 2022/11/15.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit

protocol FrontPageTableViewCellDelegate: AnyObject {
    /// 點擊電話按鈕
    func cellDidTapPhone(_ hotel: Hotel)
    /// 點擊 web 按鈕
    func cellDidTapWebsite(_ hotel: Hotel)
    /// 點擊最愛按鈕
    func cellDidTapFavorite(_ hotel: Hotel)
}

class FrontPageTableViewCell: UITableViewCell {
    static let cellIdenifier = "FrontPageIdenifier"
    
    weak var delegate: FrontPageTableViewCellDelegate?
    private var hotel: Hotel?
    
    @IBOutlet weak var hotelimageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    ///旅館民宿之管理權責單位代碼
    @IBOutlet weak var govLabel: UILabel!
    ///星級
    @IBOutlet weak var gradeLabel: UILabel!

    ///介紹
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var hotleCalssLabel: UILabel!
    @IBOutlet weak var addLabel: UILabel!
    
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var webBtn: UIButton!
    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet weak var collectionsBtn: UIButton!
    
    @IBOutlet weak var govView: UIView! {
        didSet {
            govView.addRoundBorder()
        }
    }
 
    @IBOutlet weak var buttonView: UIView! {
        didSet {
            buttonView.addRoundBorder()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with hotel: Hotel) {
        self.hotel = hotel
        
        // 基本資訊
        self.nameLabel.text = hotel.name
        self.descriptionLabel.text = hotel.description
        self.govLabel.text = hotel.id
        
        // 圖片處理 (使用 Hotel 裡的 images array)
        let imageUrl = hotel.images.first?.url ?? ""
        self.hotelimageView.loadUrlImage(urlString: imageUrl) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.hotelimageView.image = image ?? UIImage(named: "iconError")
            case .failure:
                self.hotelimageView.image = UIImage(named: "iconError")
            }
        }
        
        // 星級
        self.gradeLabel.isHidden = hotel.hotelClass == .unknown
        self.gradeLabel.text = hotel.hotelClass.starDescription
        
        // 價格
        self.priceLabel.text = "： \(hotel.priceDisplayText)"
        
        // 旅店類別
        self.hotleCalssLabel.text = "：\(hotel.hotelClass.description)"
        
        // 地址
        self.addLabel.text = hotel.fullAddress
    }
    
    @IBAction func phoneTapped() {
        guard let hotel else { return }
        self.delegate?.cellDidTapPhone(hotel)
    }

    @IBAction func webTapped() {
        guard let hotel else { return }
        self.delegate?.cellDidTapWebsite(hotel)
    }

    @IBAction func favoriteTapped() {
        guard let hotel else { return }
        self.delegate?.cellDidTapFavorite(hotel)
    }
}

