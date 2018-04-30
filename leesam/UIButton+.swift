//
//  UIButton+.swift
//  relatedstocks
//
//  Created by 영준 이 on 2017. 1. 25..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import UIKit

extension UIButton{
    @IBInspectable
    var templatedSelectedImage : UIImage?{
        get{
            return self.image(for: .selected);
        }
        
        set(value){
            let image = value?.withRenderingMode(.alwaysTemplate);
            self.setImage(image, for: .selected);
        }
    }
    
    @IBInspectable
    var templatedImage : UIImage?{
        get{
            return self.image(for: .normal);
        }
        
        set(value){
            let image = value?.withRenderingMode(.alwaysTemplate);
            self.setImage(image, for: .normal);
        }
    }
}
