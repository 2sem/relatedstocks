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
    
    var topMargin : CGFloat = 8.0;
    var bottomMargin : CGFloat = 8.0;
    var onlyTitleConstraints : [NSLayoutConstraint] = [];
    var titleKeywordConstraints : [NSLayoutConstraint] = [];
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard self.checkButton != nil else{
            return;
        }
        self.checkButton.setBackgroundImage(nil, for: .selected);
        self.setupLayouts();
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setupLayouts(){
        if self.onlyTitleConstraints.isEmpty{
            self.onlyTitleConstraints.append(self.titleLabel.centerYAnchor.constraint(equalTo: self.iconImage.centerYAnchor));
        }
        
        if self.titleKeywordConstraints.isEmpty && self.keywordLabel != nil{
            self.titleKeywordConstraints.append(self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: self.topMargin));
            self.titleKeywordConstraints.append(self.keywordLabel.firstBaselineAnchor.constraint(equalTo: self.titleLabel.lastBaselineAnchor, constant: 22));
            self.titleKeywordConstraints.append(self.contentView.bottomAnchor.constraint(greaterThanOrEqualTo: self.keywordLabel.lastBaselineAnchor, constant: self.bottomMargin));
        }
    }
    
    func updateLayouts(){
        self.setupLayouts();
        if let keyword = self.keywordLabel.text, keyword.any{
            NSLayoutConstraint.deactivate(self.onlyTitleConstraints);
            NSLayoutConstraint.activate(self.titleKeywordConstraints);
        }else{
            NSLayoutConstraint.deactivate(self.titleKeywordConstraints);
            NSLayoutConstraint.activate(self.onlyTitleConstraints);
        }
    }
}
