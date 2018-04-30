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

    // MARK: Constraints for Admob Banner
    @IBOutlet var constraint_bottomBanner_Bottom : NSLayoutConstraint!;
    var constraint_bottomBanner_Top : NSLayoutConstraint!;
    
    @IBOutlet weak var bottomBannerView: GADBannerView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var reviewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.constraint_bottomBanner_Top = self.bottomBannerView.topAnchor.constraint(equalTo: self.view.bottomAnchor);
        self.showBanner(visible: false);
        
        self.bottomBannerView?.adUnitID = "ca-app-pub-9684378399371172/5039142843";
        self.bottomBannerView?.rootViewController = self;
        self.bottomBannerView?.isHidden = false;
        
        let req = GADRequest();
        //req.testDevices = ["5fb1f297b8eafe217348a756bdb2de56"];
        
        self.bottomBannerView.delegate = self;
        
        GADInterstialManager.shared?.delegate = self;
        GADRewardManager.shared?.delegate = self;
        
        guard (GADRewardManager.shared?.canShow ?? false) else{
            return;
        }
        self.bottomBannerView?.load(req);
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
    
    
    
    // MARK: Bottom Links to go to Naver/Paxnet
    @IBAction func onGoNaverRank(_ sender: UIButton) {
        //Open Naver Stock Rank Page
        if let internetView = self.storyboard?.instantiateViewController(withIdentifier: "RSInternetViewController") as? RSInternetViewController{
            internetView.startingUrl = "http://m.stock.naver.com/sise/siseList.nhn?menu=top_search&sosok=2#siseMenuList";
            (RSTabbarController.shared.selectedViewController as? UINavigationController)?.pushViewController(internetView, animated: true);
        }
    }
    
    @IBAction func onGoNaverNews(_ sender: UIButton) {
        //Open Naver Stock News Page
        if let internetView = self.storyboard?.instantiateViewController(withIdentifier: "RSInternetViewController") as? RSInternetViewController{
            internetView.startingUrl = "http://m.stock.naver.com/news/index.nhn?category=ranknews";
            (RSTabbarController.shared.selectedViewController as? UINavigationController)?.pushViewController(internetView, animated: true);
        }
    }
    
    @IBAction func onGoPaxnetRank(_ sender: UIButton) {
        //Open Paxnet Stock Stock Page
        if let internetView = self.storyboard?.instantiateViewController(withIdentifier: "RSInternetViewController") as? RSInternetViewController{
            internetView.startingUrl = "http://paxnet.moneta.co.kr/stock/sise/totalRanking";
            (RSTabbarController.shared.selectedViewController as? UINavigationController)?.pushViewController(internetView, animated: true);
        }
    }
    
    @IBAction func onGoPaxnetNews(_ sender: UIButton) {
        //Open Paxnet Stock News Page
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
    
    // MARK: GADInterstialManagerDelegate
    func GADInterstialGetLastShowTime() -> Date {
        return RSDefaults.LastFullADShown;
    }
    
    func GADInterstialUpdate(showTime: Date) {
        RSDefaults.LastFullADShown = showTime;
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
