//
//  DescriptionTableViewCell.swift
//  寶島旅社
//
//  Created by Eric Lin on 2022/10/25.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var roundFramView: UIView! {
        didSet {
            roundFramView.addRoundBorder()
        }
    }
    @IBOutlet weak var descriptionTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func configure(dataModel: Hotel) {
        descriptionTextView.text = dataModel.description
    }
}
