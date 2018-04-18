//
//  MainViewController.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 16..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MainViewController: UIViewController, GADBannerViewDelegate, GADInterstialManagerDelegate, GADRewardManagerDelegate{

    class Constraints{
        static let BottomBanner_BOTTOM = "bottomBanner_BOTTOM";
    }
    
    var constraint_bottomBanner_Bottom : NSLayoutConstraint!;
    var constraint_bottomBanner_Top : NSLayoutConstraint!;
    
    @IBOutlet weak var bottomBannerView: GADBannerView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var reviewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.constraint_bottomBanner_Bottom = self.view.getConstraint(identifier: Constraints.BottomBanner_BOTTOM);
        self.constraint_bottomBanner_Top = self.bottomBannerView.topAnchor.constraint(equalTo: self.view.bottomAnchor);
        self.showBanner(visible: false);
        
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: .UIKeyboardWillShow, object: nil);
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: .UIKeyboardWillHide, object: nil);

//        self.bottomBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait);
        self.bottomBannerView?.adUnitID = "ca-app-pub-9684378399371172/5039142843";
        self.bottomBannerView?.rootViewController = self;
        self.bottomBannerView?.isHidden = false;
//        self.bottomBanner?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44);
//        self.bottomBannerView?.frame.origin.y = self.view.frame.height - self.bottomBannerView.frame.height;
//        self.view.addSubview(self.bottomBannerView);
        var view : UIViewController;
//        self.bottomBanner?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true;
//        self.bottomBanner?.heightAnchor.constraint(equalToConstant: 200).isActive = true;
//        self.bottomBanner?.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true;
//        self.bottomBanner?.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true;
//        self.bottomBanner.layoutIfNeeded();
        var req = GADRequest();
        //req.testDevices = ["5fb1f297b8eafe217348a756bdb2de56"];
        
        self.bottomBannerView.delegate = self;
        
        GADInterstialManager.shared?.delegate = self;
        GADRewardManager.shared?.delegate = self;
        
        //&& (GADInterstialManager.shared?.canShow ?? false)
        guard (GADRewardManager.shared?.canShow ?? false) else{
            return;
        }
        self.bottomBannerView?.load(req);
        
//        var rateUrl = URL(string: "itms-apps://itunes.apple.com/gwanlyeonjusiggeomsaeggi/id1189758512");
//        UIApplication.shared.openReview("1189758512");
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onReviewButton(_ sender: UIButton) {
        UIApplication.shared.openReview();
    }
    
    func toggleContraint(value : Bool, constraintOn : NSLayoutConstraint, constarintOff : NSLayoutConstraint){
        if constraintOn.isActive{
            constraintOn.isActive = value;
            constarintOff.isActive = !value;
        }else{
            constarintOff.isActive = !value;
            constraintOn.isActive = value;
        }
    }
    
    private func showBanner(visible: Bool){
        self.toggleContraint(value: visible, constraintOn: constraint_bottomBanner_Bottom, constarintOff: constraint_bottomBanner_Top);
        
        if visible{
            print("show banner");
        }else{
            print("hide banner");
        }
        self.bottomBannerView.isHidden = !visible;
    }
    
    @IBAction func onGoNaverRank(_ sender: UIButton) {
        if let internetView = self.storyboard?.instantiateViewController(withIdentifier: "RSInternetViewController") as? RSInternetViewController{
            internetView.startingUrl = "http://m.stock.naver.com/sise/siseList.nhn?menu=top_search&sosok=2#siseMenuList";
            (RSTabbarController.shared.selectedViewController as? UINavigationController)?.pushViewController(internetView, animated: true);
        }
    }
    
    @IBAction func onGoNaverNews(_ sender: UIButton) {
        if let internetView = self.storyboard?.instantiateViewController(withIdentifier: "RSInternetViewController") as? RSInternetViewController{
            internetView.startingUrl = "http://m.stock.naver.com/news/index.nhn?category=ranknews";
            (RSTabbarController.shared.selectedViewController as? UINavigationController)?.pushViewController(internetView, animated: true);
        }
    }
    
    @IBAction func onGoPaxnetRank(_ sender: UIButton) {
        if let internetView = self.storyboard?.instantiateViewController(withIdentifier: "RSInternetViewController") as? RSInternetViewController{
            internetView.startingUrl = "http://paxnet.moneta.co.kr/stock/sise/totalRanking";
            (RSTabbarController.shared.selectedViewController as? UINavigationController)?.pushViewController(internetView, animated: true);
        }
    }
    
    @IBAction func onGoPaxnetNews(_ sender: UIButton) {
        if let internetView = self.storyboard?.instantiateViewController(withIdentifier: "RSInternetViewController") as? RSInternetViewController{
            internetView.startingUrl = "http://news.moneta.co.kr/Service/mobile/introlist.asp";
            (RSTabbarController.shared.selectedViewController as? UINavigationController)?.pushViewController(internetView, animated: true);
        }
    }
    
    /// MARK: GADBannerViewDelegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.showBanner(visible: true);
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        self.showBanner(visible: false);
    }
    
    var keyboardEnabled = false;
    func keyboardWillShow(noti: Notification){
        print("keyboard will show move view to upper -- \(noti.object)");
        //        if self.nativeTextView.isFirstResponder {
        if !keyboardEnabled {
            keyboardEnabled = true;
            //            self.viewContainer.frame.origin.y -= 180;
            var frame = noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect;
            
            // - self.bottomBannerView.frame.height
            if true{ //!self.isIPhone
                var remainHeight = (frame?.height ?? 0);//self.view.frame.height -
//                var remainHeight : CGFloat = 100.0;
                self.constraint_bottomBanner_Top.constant = -remainHeight;
                self.constraint_bottomBanner_Bottom.constant = -remainHeight;
            }
            
            //            self.viewContainer.layoutIfNeeded();
        };
        //native y -= (keyboard height - bottom banner height)
        // keyboard top == native bottom
        //        }
    }
    
    func keyboardWillHide(noti: Notification){
        print("keyboard will hide move view to lower  -- \(noti.object)");
        //        if self.nativeTextView.isFirstResponder{
        
        //        }
        //&&
        if keyboardEnabled {
            keyboardEnabled = false;
            //            self.viewContainer.frame.origin.y += 180;
            
            self.constraint_bottomBanner_Top.constant = 0;
            self.constraint_bottomBanner_Bottom.constant = 0;
            //            self.viewContainer.layoutIfNeeded();
        };
    }
    
    // MARK: GADInterstialManagerDelegate
    func GADInterstialGetLastShowTime() -> Date {
        return RSDefaults.LastFullADShown;
        //Calendar.current.component(<#T##component: Calendar.Component##Calendar.Component#>, from: <#T##Date#>)
    }
    
    func GADInterstialUpdate(showTime: Date) {
        RSDefaults.LastFullADShown = showTime;
        //self.showBanner(visible: false);
    }
    
    // MARK: GADRewardManagerDelegate
    func GADRewardGetLastShowTime() -> Date {
        return RSDefaults.LastRewardADShown;
    }
    
    func GADRewardUpdate(showTime: Date) {
        RSDefaults.LastRewardADShown = showTime;
    }
    
    func GADRewardUserCompleted() {
        self.showBanner(visible: false);
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
