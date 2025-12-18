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
        nameLabel.text = hotel.hotelName
        
        hotelimageView.loadUrlImage(urlString: hotel.images.first?.url ?? "") { result in
            switch result {
            case .success(let image):
                if let image = image {
                    self.hotelimageView.image = image
                } else {
                    self.hotelimageView.image = UIImage(named: "iconError")
                }
            case .failure(_):
                self.hotelimageView.image = UIImage(named: "iconError")
            }
        }
        
        // 星级
        if hotel.hotelStars > 0 {
            gradeLabel.isHidden = false
            gradeLabel.text = "☆級：\(hotel.hotelStars)"
        } else {
            gradeLabel.isHidden = true
        }
        
        govLabel.text = hotel.hotelID
        descriptionLabel.text = hotel.description
        
        // 價格
        let priceText = hotel.lowestPrice != hotel.ceilingPrice ? "\(hotel.lowestPrice) ~ \(hotel.ceilingPrice)" : "\(hotel.ceilingPrice)"
        priceLabel.text = "： \(priceText)"
        
        // 旅店類别
        if let hotelClass = hotel.hotelClasses.first.flatMap(HotelClass.init(rawValue:)) {
            hotleCalssLabel.text = "：\(hotelClass.description)"
        } else {
            hotleCalssLabel.text = "旅店未提供"
        }
        
        let formattedAddress = String.formattedAddress(region: hotel.address.city,
                                                       town: hotel.address.town,
                                                       add: hotel.address.streetAddress)
        addLabel.text = formattedAddress
    }
    
    @IBAction func phoneTapped() {
        guard let hotel else { return }
        delegate?.cellDidTapPhone(hotel)
    }

    @IBAction func webTapped() {
        guard let hotel else { return }
        delegate?.cellDidTapWebsite(hotel)
    }

    @IBAction func favoriteTapped() {
        guard let hotel else { return }
        delegate?.cellDidTapFavorite(hotel)
    }
}

