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
        self.viewModel.delegate = self
    }
}

//MARK: - Private

extension AboutViewController {
    
    private func setupUI() {
        navigationItem.title = "關於"
        self.kanaheiImageView.loadGif(name: GifImageNames.shared.aboutImageName)
        
        // 註冊 Cell
        self.tableView.register(PersonalSettingsLanguageTableViewCell.self, forCellReuseIdentifier: PersonalSettingsLanguageTableViewCell.storyboardIdentifier)
        
        self.tableView.register(PersonalSettingsIconTableViewCell.self, forCellReuseIdentifier: PersonalSettingsIconTableViewCell.storyboardIdentifier)
        
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


//MARK: - AboutViewModelDelegate

extension AboutViewController: AboutViewModelDelegate {

    func reloadData() {
        self.tableView.reloadData()
    }

    func viewModelDidFail(_ error: Error) {
        DispatchQueue.main.async {
            LoadingPageView.shard.dismiss()
            self.view.showToast(text: "資料讀取失敗")
            #if DEBUG
            print(error)
            #endif
        }
    }
    
    func onDownloadSuccess(isAlreadyLatest: Bool) {
        let message = isAlreadyLatest ? "目前的資料庫已是最新版本囉！" : "資料更新完成！目前共有 \(HotelDataManager.shared.totalCount) 筆旅宿。"
        self.view.showToast(text: message)
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
        let rowModel = self.viewModel.rowModel(at: indexPath)
        
        switch rowModel.type {
        case .downloadData:
            // 下載 Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: PersonalSettingsIconTableViewCell.storyboardIdentifier, for: indexPath) as! PersonalSettingsIconTableViewCell
            
            cell.configure(systemName: rowModel.iconName ?? "",
                           title: rowModel.type.title)
            return cell
            
        default:
            // 一般 Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: PersonalSettingsLanguageTableViewCell.storyboardIdentifier, for: indexPath) as! PersonalSettingsLanguageTableViewCell
            cell.configure(title: rowModel.type.title, subtitle: rowModel.subtitle)
            
            // 只有資料來源可以點擊跳網頁
            cell.accessoryType = rowModel.isClickable ? .disclosureIndicator : .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 取得該 Row 的資料模型
        let rowModel = self.viewModel.rowModel(at: indexPath)
        
        switch rowModel.type {
        case .apiSource:
            self.navigateToWebView()
        case .downloadData:
            // 還在檢查版本中（API 還沒噴回來）
            if self.viewModel.syncState == .checking {
                self.view.showToast(text: "正在檢查版本資訊...")
                return
            }
            
            // 已經是最新的
            if self.viewModel.syncState == .upToDate {
                self.view.showToast(text: "目前已是最新版本")
                return
            }
            
            let message = "即將連線下載全台旅宿資料\n預計大小：約 4.5 MB\n建議使用 Wi-Fi 環境下載。"
          
            self.showAlertClosure(title: "下載離線資料",
                                  message: message,
                                  okBtn: "開始下載",
                                  handler: {
                self.viewModel.fetchLatestData()
            })
        default:
            // 其他項目目前不需處理點擊
            break
        }
    }
}
