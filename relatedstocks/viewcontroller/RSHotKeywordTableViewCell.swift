//
//  RSHotKeywordTableViewCell.swift
//  relatedstocks
//
//  Created by 영준 이 on 2018. 6. 4..
//  Copyright © 2018년 leesam. All rights reserved.
//

import UIKit

class RSHotKeywordTableViewCell: UITableViewCell {

    @IBOutlet weak var keywordLabel: UILabel!
    @IBOutlet weak var newIconImage: UIImageView!
    
    private var newAnimator : UIViewPropertyAnimator!;
    var showNewIndicator : Bool = false{
        didSet{
            if self.showNewIndicator{
                self.newIconImage.isHidden = false;
                
                self.newIconImage.alpha = 1.0;
                self.newAnimator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1.0, delay: 0.0, options: [.curveEaseOut,.repeat], animations: { [weak self] in
                    UIView.setAnimationRepeatCount(3);
                    UIView.setAnimationRepeatAutoreverses(true);
                    self?.newIconImage?.alpha = 0.0;
                }) { [weak self](position) in
                    self?.newIconImage?.alpha = 1.0;
                }
            }else{
                if self.newAnimator.isRunning{
                    self.newAnimator?.stopAnimation(false);
                }
                self.newIconImage.isHidden = true;
            }
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

}
