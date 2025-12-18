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
    
    // MARK: - Outlets
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet weak var kanaheiImageView: UIImageView!
    
    weak var delegate: HotelSearchViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
        commonInit() // 初始化 UI 設定
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
        commonInit() // 初始化 UI 設定
    }
    
    private func loadFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "HotelSearchView", bundle: bundle)
        
        guard let contentView = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    
    private func commonInit() {
        setupUI()
        setupGesture()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        searchTextField.delegate = self
        backgroundView.alpha = 0.6
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundView.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    @IBAction private func searchTapped() {
        let keyword = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !keyword.isEmpty else {
            self.showToast(text: "查詢條件未輸入哦")
            return
        }
        
        delegate?.hotelSearchViewDidTapSearch(self, keyword: keyword)
    }
    
    @IBAction private func cancelTapped() {
        clear()
        delegate?.hotelSearchViewDidTapCancel(self)
    }
    
    @objc private func backgroundTapped() {
        hide()
    }
    
    func show() {
        isHidden = false
        searchTextField.becomeFirstResponder()
    }
    
    func hide() {
        endEditing(true)
        isHidden = true
    }
    
    func clear() {
        searchTextField.text = ""
    }
}

//MARK: - UITextFieldDelegate

extension HotelSearchView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTapped()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
}
