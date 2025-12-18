//
//  LoadingPageView.swift
//  MessageDemo
//
//  Created by Eric Lin on 2022/10/14.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit

class LoadingPageView: CustomView {
    
    @IBOutlet weak private var loadingImageView: UIImageView!
    @IBOutlet weak private var progress: UIProgressView!
    
    private lazy var loadingPageView: LoadingPageView? = LoadingPageView(frame: UIScreen.main.bounds)
    private lazy var timer = Timer()
    
    static let shard = LoadingPageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        
        loadingImageView.image = UIImage.gif(name: GifImageNames.shared.loadingImageName)
        
        progress.trackTintColor = UIColor.white
        progress.progressTintColor = UIColor(red: 0.29, green: 0.698, blue: 0.204, alpha: 1)
        progress.layer.masksToBounds = true;
        progress.layer.cornerRadius = 3;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///show Loading GiF View
    func show() {
        UIApplication.addViewOnTopWindow(view: loadingPageView ?? UIView())
        timer = Timer.scheduledTimer(timeInterval: 0.13, target: self, selector: #selector(timerActionForLoadingPage), userInfo: nil, repeats: true)
    }
    
    @objc func timerActionForLoadingPage() {
        loadingPageView?.progress.setProgress(loadingPageView!.progress.progress + 0.03, animated: true)
    }
    
    ///dismiss Loading GiF View
    func dismiss() {
        timer.invalidate()
        loadingPageView?.removeFromSuperview()
    }
}
