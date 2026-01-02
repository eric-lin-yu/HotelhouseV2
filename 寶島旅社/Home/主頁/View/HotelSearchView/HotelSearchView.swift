//
//  HotelSearchView.swift
//  寶島旅社
//
//  Created by wistronits on 2025/12/18.
//  Copyright © 2025 Eric Lin. All rights reserved.
//

import UIKit

protocol HotelSearchViewDelegate: AnyObject {
    /// 點擊查詢
    func hotelSearchViewDidTapSearch(_ view: HotelSearchView, keyword: String)
    
    /// 點擊取消（X）
    func hotelSearchViewDidTapCancel(_ view: HotelSearchView)
}

class HotelSearchView: UIView {
    
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var searchTextField: UITextField! {
        didSet {
            self.searchTextField.addRoundBorder()
        }
    }
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet weak var kanaheiImageView: UIImageView!
    
    weak var delegate: HotelSearchViewDelegate?
    
    /// 記錄目前是否允許關閉
    private var isClosable: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadFromNib()
        
        self.setupUI()
        self.setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 顯示搜尋頁面
    /// - Parameter canCancel: 是否允許取消（若為 false，則隱藏 X 按鈕且點擊背景無效）
    func show(canCancel: Bool = true) {
        self.isClosable = canCancel
        self.cancelButton.isHidden = !canCancel // 如果不能取消，就把 X 隱藏
        self.isHidden = false
    }
    
    /// 隱藏搜尋頁面
    /// - Parameter force: 是否強制隱藏（無視 isClosable 狀態，用於程式觸發）
    func hide(force: Bool = false) {
        if !force {
            // 如果不是強制隱藏，才需要檢查是否允許關閉
            guard self.isClosable else { return }
        }
        
        endEditing(true)
        self.isHidden = true
    }
    
    func clear() {
        self.searchTextField.text = ""
    }
}

// MARK: - Private
extension HotelSearchView {
    
    private func loadFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "HotelSearchView", bundle: bundle)
        
        guard let contentView = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    
    private func setupUI() {
        self.searchTextField.delegate = self
        self.backgroundView.addBlurBackground(style: .dark, alpha: 0.9)
        self.kanaheiImageView.loadGif(name: GifImageNames.shared.searchViewImageName)
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        self.backgroundView.addGestureRecognizer(tap)
    }
}

// MARK: - Actions
extension HotelSearchView {
    /// 點擊搜尋按鈕
    @IBAction private func searchTapped() {
        let keyword = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !keyword.isEmpty else {
            self.showToast(text: "查詢條件未輸入哦")
            return
        }
        
        self.delegate?.hotelSearchViewDidTapSearch(self, keyword: keyword)
    }

    /// 點擊背景空白處
    @objc private func backgroundTapped() {
        if self.isClosable {
            self.hide()
        }
    }

    /// 點擊取消按鈕
    @IBAction private func cancelTapped() {
        // 只有在允許取消時才執行
        if self.isClosable {
            self.clear()
            self.delegate?.hotelSearchViewDidTapCancel(self)
        }
    }
}

//MARK: - UITextFieldDelegate

extension HotelSearchView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTapped()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
}
