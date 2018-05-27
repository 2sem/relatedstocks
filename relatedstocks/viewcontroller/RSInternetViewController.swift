//
//  RSInternetViewController.swift
//  relatedstocks
//
//  Created by 영준 이 on 2017. 12. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import ProgressWebViewController
import KakaoLink
import KakaoMessageTemplate
import CoreData

class RSInternetViewController: ProgressWebViewController {
    
    @objc var company : String = "";
    var keyword : String = "";
    
    var originalRightButtons : [UIBarButtonItem] = [];
    var naverUrlForCompany : URL{
        return URL(string: "http://search.naver.com/search.naver?ie=utf8&query=\(self.company.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")")!;
    }
    @objc var startingUrl : String = "";
    var favorOnButton : UIBarButtonItem!;
    var favorOffButton : UIBarButtonItem!;
    var shareButton : UIBarButtonItem!;
    
    var modelController : RSModelController{
        return RSModelController.shared;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.toolbarItemTypes = [.back, .forward, .reload];
        self.websiteTitleInNavigationBar = false;
    }
    
    override func viewDidLoad() {
        self.originalRightButtons = self.navigationItem.rightBarButtonItems ?? [];
        self.toolbarItemTypes = [.back, .forward, .flexibleSpace, .reload];
        super.viewDidLoad();
        // Do any additional setup after loading the view.
        //self.url = DASponsor.Urls.historyUrl;
        //self.load(DASponsor.Urls.historyUrl);
        
        //if there is not starting url
        if self.startingUrl.isEmpty{
            self.favorOnButton = UIBarButtonItem.init(image: UIImage.init(named: "love_off.png"), style: .plain, target: self, action: #selector(self.onFavor(button:)));
            self.favorOffButton = UIBarButtonItem.init(image: UIImage.init(named: "love_on.png"), style: .plain, target: self, action: #selector(self.offFavor(button:)));
            self.shareButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(self.onShare(_:)));
            //load naver page
            self.navigationItem.title = self.company;
            self.updateRightbuttons();
            
            self.load(self.naverUrlForCompany);
        }else{
            self.navigationItem.rightBarButtonItems = [];
            self.load(URL(string: self.startingUrl)!);
        }
        self.websiteTitleInNavigationBar = true;
        self.hidesBottomBarWhenPushed = false;
        //self.navigationController?.isNavigationBarHidden = false;
        //self.toolbarController?.toolbar.isHidden = true;
        //self.updateBarButtonItems()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateRightbuttons(){
        var buttons : [UIBarButtonItem] = [];
        
        buttons.append(self.shareButton);
        if self.company != "특징주"{
            if let _ = self.modelController.findStocks(withName: self.company).first{
                buttons.append(self.favorOffButton);
            }else{
                buttons.append(self.favorOnButton);
            }
        }
        
        self.navigationItem.rightBarButtonItems = buttons;
    }
    
    @objc func onFavor(button: UIBarButtonItem){
        self.modelController.createStock(name: self.company, keyword: self.keyword);
        self.modelController.saveChanges();
        self.updateRightbuttons();
    }
    
    @objc func offFavor(button: UIBarButtonItem){
        if let stock = self.modelController.findStocks(withName: self.company).first{
            self.modelController.removeStock(stock: stock);
            self.modelController.saveChanges();
            self.updateRightbuttons();
        }
    }
    
    @objc func onShare(_ sender: UIBarButtonItem) {
        DispatchQueue.main.syncInMain {
            self.shareByKakao();
        }
        return;
        /*let acts = [UIAlertAction(title: "'\(self.company)' 공유", style: .default) { (act) in
            let name = self.nibBundle?.infoDictionary?["CFBundleDisplayName"] ?? "";
            self.share(["\(self.url?.absoluteString)\n#\(name)"]);
            },
                    UIAlertAction(title: "앱 추천하기", style: .default) { (act) in
                        self.share(["\(UIApplication.shared.urlForItunes.absoluteString)"]);
            },
                    UIAlertAction(title: "취소", style: .cancel, handler: nil)]
        self.showAlert(title: "주식 공유", msg: "친구들에게 '\(self.title ?? "")'을(를) 공유하거나 관련주식검색기를 추천하세요", actions: acts, style: .alert);*/
    }
    
    func shareByKakao(){
        let kakaoLink = KMTLinkObject();
        kakaoLink.webURL = self.url;
        kakaoLink.iosExecutionParams = "category=naver&item=\(self.company)"
            + (self.keyword.any ? "&keyword=\(self.keyword)" : "")
        kakaoLink.iosExecutionParams = kakaoLink.iosExecutionParams!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed);
        kakaoLink.androidExecutionParams = kakaoLink.iosExecutionParams;
        
        //var kakaoContent = KLKContentObject(title: UIApplication.shared.displayName ?? "", imageURL: URL.init(string: "https://is1-ssl.mzstatic.com/image/thumb/Newsstand122/v4/f4/82/d5/f482d52f-18e7-3bad-03b7-f93b01379478/Icon-76@2x.png.png/0x0ss.png")!, link: kakaoLink);
        let kakaoContent = KMTContentObject(title: "추천 종목", imageURL: URL.init(string: "http://andy3938.cafe24.com/stockseeker_512.png")!, link: kakaoLink);
        kakaoContent.imageWidth = 120;
        kakaoContent.imageHeight = 120;
        
        if self.keyword.any{
            kakaoContent.desc = "\(self.company) - \(self.keyword) 테마주";
        }else{
            kakaoContent.desc = self.company;
        }
        
        let kakaoTemplate = KMTFeedTemplate.init(builderBlock: { (kakaoBuilder) in
            kakaoBuilder.content = kakaoContent;
            //kakaoBuilder.buttons?.add(kakaoWebButton);
            //link can't have more than two buttons
            // - content's url, button1 url, button2 url
            
            kakaoBuilder.addButton(KMTButtonObject(builderBlock: { (buttonBuilder) in
                buttonBuilder.link = KMTLinkObject(builderBlock: { (linkBuilder) in
                    linkBuilder.webURL = kakaoLink.webURL;
                    linkBuilder.iosExecutionParams = kakaoLink.iosExecutionParams;
                    linkBuilder.androidExecutionParams = kakaoLink.androidExecutionParams;
                })
                buttonBuilder.title = "앱으로 열기";
            }));
            /*kakaoBuilder.addButton(KLKButtonObject(builderBlock: { (buttonBuilder) in
             buttonBuilder.link = KLKLinkObject(builderBlock: { (linkBuilder) in
             if let webUrl = cell.info.personHomepage?.url, !webUrl.isEmpty{
             linkBuilder.webURL = URL(string: cell.info.personHomepage?.url ?? "");
             //kakaoLink.webURL = URL(string:"http://www.assembly.go.kr/assm/memPop/memPopup.do?dept_cd=9770941")!;
             linkBuilder.mobileWebURL = URL(string: cell.info.personHomepage?.url ?? "");
             //kakaoLink.mobileWebURL = URL(string:"http://www.assembly.go.kr/assm/memPop/memPopup.do?dept_cd=9770941")!;
             }
             })
             buttonBuilder.title = "앱에서 보기";
             }));*/
        })
        
        KLKTalkLinkCenter.shared().sendDefault(with: kakaoTemplate, success: { (warn, args) in
            
        }, failure: { (error) in
            
        })
    }
    //        self.navigationController?.navigationBar.setBackgroundImage(UIImage, for: .default);
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //        guard self.url != nil else{
}

