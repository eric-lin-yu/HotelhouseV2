//
//  AboutViewController.swift
//  寶島旅社
//
//  Created by Eric Lin on 2022/10/14.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var kanaheiImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: AboutViewModel
    
    init(viewModel: AboutViewModel) {
        self.viewModel = viewModel
        super.init(nibName: AboutViewController.className, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
}

//MARK: - Private

extension AboutViewController {
    
    private func setupUI() {
        navigationItem.title = "關於"
        self.kanaheiImageView.loadGif(name: GifImageNames.shared.aboutImageName)
        
        // 註冊 Cell
        self.tableView.register(PersonalSettingsLanguageTableViewCell.self, forCellReuseIdentifier: PersonalSettingsLanguageTableViewCell.storyboardIdentifier)
    }
    
    /// 執行跳轉至網頁
    private func navigateToWebView() {
        let vc = OpenWKWebViewController.make(urlString: "https://data.gov.tw/dataset/7780",
                                              title: "政府資料開放平臺")
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
        // 設定返回按鈕標題
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

//MARK: - TableView
extension AboutViewController: UITableViewDataSource, UITableViewDelegate {
    // section
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionType = viewModel.contents[section].section
        return SettingsTableViewHeaderFooterView(title: sectionType.title,
                                                 reuseIdentifier: SettingsTableViewHeaderFooterView.reuseIdentifier)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SettingsTableViewHeaderFooterView.height
    }
    
    // row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PersonalSettingsLanguageTableViewCell.storyboardIdentifier, for: indexPath) as! PersonalSettingsLanguageTableViewCell
        
        let rowModel = self.viewModel.rowModel(at: indexPath)
        
        cell.configure(title: rowModel.type.title, subtitle: rowModel.subtitle)
        
        // 根據是否可點擊調整樣式
        cell.accessoryType = rowModel.isClickable ? .disclosureIndicator : .none
        cell.selectionStyle = rowModel.isClickable ? .default : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取得該 Row 的資料模型
        let rowModel = self.viewModel.rowModel(at: indexPath)
        
        switch rowModel.type {
        case .apiSource:
            self.navigateToWebView()
        default:
            // 其他項目目前不需處理點擊
            break
        }
    }
}
