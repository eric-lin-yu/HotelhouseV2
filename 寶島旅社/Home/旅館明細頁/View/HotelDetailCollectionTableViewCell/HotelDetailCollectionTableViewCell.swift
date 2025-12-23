//
//  HotelDetailCollectionTableViewCell.swift
//  寶島旅社
//
//  Created by Eric Lin on 2022/11/4.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit

class HotelDetailCollectionTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.showsHorizontalScrollIndicator = false //關閉水平滑動bar效果
        }
    }
    @IBOutlet weak var pageControl: UIPageControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
