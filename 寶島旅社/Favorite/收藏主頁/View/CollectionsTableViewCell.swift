//
//  CollectionsTableViewCell.swift
//  寶島旅社
//
//  Created by wistronits on 2023/10/3.
//  Copyright © 2023 Eric Lin. All rights reserved.
//

import UIKit

protocol CollectionsTableViewCellDelegate: AnyObject {
    /// 點擊刪除
    func didTapDelete(hotel: Hotel)
    /// 點擊筆記按鈕
    func didTapEditNote(hotel: Hotel)
    /// 點擊更多
    func didTapMoreInfo(hotel: Hotel)
}

class CollectionsTableViewCell: UITableViewCell {

    @IBOutlet weak var hotelTitleLabel: UILabel!
    @IBOutlet weak var hotelImageView: UIImageView!
    @IBOutlet weak var organizationsView: UIView! {
        didSet {
            organizationsView.addRoundBorder()
        }
    }
    @IBOutlet weak var organizationsTitle: UILabel!
    @IBOutlet weak var organizationsHotelId: UILabel!
    @IBOutlet weak var organizationsHotelStars: UILabel!
    @IBOutlet weak var bottomButtonView: UIView! {
        didSet {
            bottomButtonView.addRoundBorder()
        }
    }

    weak var delegate: CollectionsTableViewCellDelegate?
    /// 儲存當前 Cell 的資料
    private var hotel: Hotel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configure(with hotel: Hotel) {
        self.hotel = hotel
        self.hotelTitleLabel.text = hotel.name
        
        self.hotelImageView.loadUrlImage(urlString: hotel.images.first?.url ?? "") { result in
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
        self.organizationsTitle.text = "旅館民宿之管理權責單位代碼"
        self.organizationsHotelId.text = hotel.id
        
        self.organizationsHotelStars.isHidden = hotel.hotelClass == .unknown
        self.organizationsHotelStars.text = hotel.hotelClass.starDescription
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        guard let hotel = self.hotel else { return }
        self.delegate?.didTapDelete(hotel: hotel)
    }
    
    @IBAction func editNoteAction(_ sender: UIButton) {
        
        guard let hotel = self.hotel else { return }
        self.delegate?.didTapEditNote(hotel: hotel)
    }

    @IBAction func moreInfoAction(_ sender: UIButton) {
        guard let hotel = self.hotel else { return }
        self.delegate?.didTapMoreInfo(hotel: hotel)
    }
}
