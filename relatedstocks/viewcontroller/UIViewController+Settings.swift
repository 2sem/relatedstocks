//
//  UIViewController+Settings.swift
//  relatedstocks
//
//  Created by 영준 이 on 2018. 6. 5..
//  Copyright © 2018년 leesam. All rights reserved.
//

import UIKit

extension UIViewController{
    func openInternetError(){
        self.openSettingsOrCancel(title: "접속 오류", msg: "인터넷에 연결되지 않았거나 서버에 접속할 수 없습니다. 설정을 확인하거나 잠시 후 다시 시도해 주십시오.", style: .alert, titleForOK: "확인", titleForSettings: "설정");
    }
}
