//
//  HotelDetailsTableViewCell.swift
//  寶島旅社
//
//  Created by wistronits on 2022/11/16.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit

protocol HotelDetailsTableViewCellDelegate: AnyObject {
    /// 點擊收藏按鈕
    func didTapFavoriteToggle()
    /// 點擊 web
    func webLabelTapped()
}
class HotelDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var hotelClassView: UIView!
    @IBOutlet weak var hotelCalssLabel: UILabel!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var webLabel: UILabel!
    @IBOutlet weak var collectionsButton: UIButton!
    
    weak var delegate: HotelDetailsTableViewCellDelegate?
    
    private var hotelId: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(hotel: Hotel, delegate: HotelDetailsTableViewCellDelegate) {
        self.delegate = delegate
        self.hotelId = hotel.id
        
        self.hotelCalssLabel.text = "：\(hotel.hotelClass.description)"
        self.priceLabel.text = "：\(hotel.priceDisplayText)"
        
        // 檢查 Realm 狀態並設定按鈕選中狀態
        let isFavorite = RealmManager.shard?.isHotelFavorited(id: hotel.id) ?? false
        self.collectionsButton.isSelected = isFavorite
        
        // 設定網頁 Label
        if !hotel.website.isEmpty {
            self.webLabel.text = "開啟網站"
            self.webLabel.isUserInteractionEnabled = true
        } else {
            self.webLabel.text = "旅店未提供"
            self.webLabel.textColor = .black
        }
    }
    
    @objc private func openWebView() {
        delegate?.webLabelTapped()
    }
    
    @IBAction func collectionsButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapFavoriteToggle()
        
        // 根據 Realm 寫入結果更新狀態
        let isFavorite = RealmManager.shard?.isHotelFavorited(id: hotelId) ?? false
        sender.isSelected = isFavorite
    }
}
