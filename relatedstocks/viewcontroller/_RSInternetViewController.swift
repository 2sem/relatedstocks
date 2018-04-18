//
//  RSInternetViewController.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 24..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit

class RSInternetViewController_ : UIViewController, UIWebViewDelegate {

    var company = "";
    var url : URL!;
    var urlToLoad : String!;
    
    @IBOutlet weak var webView: UIWebView!
    var shareButton : UIBarButtonItem!;
    // MARK: Web Navigation Buttons
    var backButton : UIBarButtonItem!;
    var prevButton : UIBarButtonItem!;
    var nextButton : UIBarButtonItem!;
    var stopButton : UIBarButtonItem!;
    var reloadButton : UIBarButtonItem!;
    
    func onShare(button : UIBarButtonItem){
        var acts = [UIAlertAction(title: "'\(self.company)' 공유", style: .default) { (act) in
            var name = self.nibBundle?.infoDictionary?["CFBundleDisplayName"] ?? "";
            self.share(["\(self.url.absoluteString)\n#\(name)"]);
        },
        UIAlertAction(title: "앱 추천하기", style: .default) { (act) in
            self.share(["\(UIApplication.shared.urlForItunes.absoluteString)"]);
        },
        UIAlertAction(title: "취소", style: .cancel, handler: nil)]
        self.showAlert(title: "주식 공유", msg: "친구들에게 '\(self.title ?? "")'을(를) 공유하거나 관련주식검색기를 추천하세요", actions: acts, style: .alert);
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage, for: .default);
        self.navigationController?.navigationBar.barTintColor = UIColor.white;
        self.navigationController?.navigationBar.isHidden = false;
        
        if self.navigationController?.topViewController === self{
            //self.webView.goBack();
            //self.webView.goForward();
            //self.webView.stopLoading();
            //self.webView.reload();
        }
        
//        guard self.url != nil else{
//            return;
//        }
//        
//        var req = URLRequest(url: url!);
//        print("open web \(req)");
//        self.webView.loadRequest(req);
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.hidesBottomBarWhenPushed = false;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = nil;
        
        //title: "뒤로"
        self.backButton = UIBarButtonItem.init(image: UIImage(named: "double_back.png"), style: .plain, target: self, action: #selector(onBack(button:)));
        self.prevButton = UIBarButtonItem.init(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(onGoBack(button:)))
        self.nextButton = UIBarButtonItem.init(image: UIImage(named: "forward.png"), style: .plain, target: self, action: #selector(onGoForward(button:)));
        self.stopButton = UIBarButtonItem.init(image: UIImage(named: "stop.png"), style: .plain, target: self, action: #selector(onStop(button:)));
        self.reloadButton = UIBarButtonItem.init(image: UIImage(named: "refresh.png"), style: .plain, target: self, action: #selector(onReload(button:)));
        
        if self.navigationController?.viewControllers.first === self{
            self.navigationItem.leftBarButtonItems = [self.prevButton, self.nextButton];
            self.navigationItem.rightBarButtonItems = [self.reloadButton];
        }else{
            self.navigationItem.leftBarButtonItems = [self.backButton, self.prevButton, self.nextButton];
            self.navigationItem.rightBarButtonItems = [self.reloadButton, self.reloadButton];
        }
        
        self.refreshButtons();

        if self.urlToLoad == nil{
            self.loadCompany();
        }else{
            var url = URL(string: self.urlToLoad);
            var req = URLRequest(url: url!);
            self.webView.loadRequest(req);
        }
//        self.navigationController?.navigationBar.isHidden = true;
                // Do any additional setup after loading the view.
        
        guard !self.company.isEmpty else{
            return;
        }
        
        self.shareButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(onShare(button:)));
        var right = self.navigationItem.rightBarButtonItems ?? [];
        right.append(self.shareButton);
        self.navigationItem.rightBarButtonItem = self.shareButton;
    }
    
    func onBack(button : UIBarButtonItem){
        self.navigationController?.popViewController(animated: true);
    }
    func onGoBack(button : UIBarButtonItem){
        self.webView.goBack();
    }
    func onGoForward(button : UIBarButtonItem){
        self.webView.goForward();
    }
    func onStop(button : UIBarButtonItem){
        self.webView.stopLoading();
    }
    func onReload(button : UIBarButtonItem){
        self.webView.reload();
    }
    
    func refreshButtons(){
        self.prevButton.isEnabled = self.webView.canGoBack;
        self.nextButton.isEnabled = self.webView.canGoForward;
        self.stopButton.isEnabled = self.webView.isLoading;
//        self.prevButton.isEnabled = self.webView.canGoBack;
    }

    internal func loadCompany(){
        var query = company.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "";
        
        if self.url == nil && !self.company.isEmpty{
            self.url = URL(string: "http://search.naver.com/search.naver?ie=utf8&query=\(query)");
        }
        
        guard url != nil else{
            return;
        }
        
        var req = URLRequest(url: url!);
        print("open web \(req)");
        self.webView.loadRequest(req);
        
        if !company.isEmpty{
            self.title = self.company;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIWebViewDelegate
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if let urlError = error as? NSError{
            if urlError.code == -1009{
//                self.showCellularAlert(title: ".");
                self.openSettingsOrCancel(title: "인터넷에 연결할 수 없습니다", msg: "인터넷에 연결하려면, 셀룰러 데이터를 켜거나 Wi-Fi를 사용하십시오.", titleForOK: "확인", titleForSettings: "설정");
            }
        }
        print("webview loading has been failed. error[\(error)]");
        self.refreshButtons();
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.refreshButtons();
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.refreshButtons();
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
