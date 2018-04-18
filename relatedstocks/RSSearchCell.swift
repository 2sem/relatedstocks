//
//  RSSearchCell.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 26..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit

class RSSearchCell: UITableViewCell {

    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var keywordLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard self.checkButton != nil else{
            return;
        }
        self.checkButton.setBackgroundImage(nil, for: .selected);
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
