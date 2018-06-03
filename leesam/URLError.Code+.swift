//
//  URLError.Code+.swift
//  relatedstocks
//
//  Created by 영준 이 on 2018. 6. 3..
//  Copyright © 2018년 leesam. All rights reserved.
//

import Foundation

extension URLError.Code{
    var error : Error{
        return NSError(domain: "\(self)", code: self.rawValue, userInfo: nil);
    }
}
