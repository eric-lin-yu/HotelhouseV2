//
//  HotelDetailsTableViewCell.swift
//  寶島旅社
//
//  Created by wistronits on 2022/11/16.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit

protocol HotelDetailsTableViewCellDelegate: AnyObject {
    func webLabelTapped(for cell: HotelDetailsTableViewCell)
    func addHotelDataModelToRealm(for cell: HotelDetailsTableViewCell)
}
class HotelDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var hotelClassView: UIView!
    @IBOutlet weak var hotelCalssLabel: UILabel!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var webLabel: UILabel!
    @IBOutlet weak var collectionsView: UIView!
    @IBOutlet weak var collectionsImageView: UIImageView!
    
    weak var delegate: HotelDetailsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    func configure(hotel: Hotel, delegate: HotelDetailsTableViewCellDelegate) {
        self.delegate = delegate
        
        // 旅館類別
        self.hotelCalssLabel.text = "：\(hotel.hotelClass.description)"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(addHotelDataModelToRealm))
        collectionsView.isUserInteractionEnabled = true
        collectionsView.addGestureRecognizer(tap)
    
        self.priceLabel.text = "： \(hotel.priceDisplayText)"
        
        if !hotel.website.isEmpty {
            webLabel.text = "開啟網站"
            let tap = UITapGestureRecognizer(target: self, action: #selector(openWebView))
            webLabel.isUserInteractionEnabled = true
            webLabel.addGestureRecognizer(tap)
        } else {
            webLabel.text = "旅店未提供"
            webLabel.textColor = .black
        }
    }
    
    @objc private func openWebView() {
        delegate?.webLabelTapped(for: self)
    }
    
    @objc private func addHotelDataModelToRealm() {
        delegate?.addHotelDataModelToRealm(for: self)
    }
}
