//
//  ViewController.swift
//  寶島旅社
//
//  Created by Eric Lin. on 2022/10/12.
//

import UIKit
import MessageUI
import SkeletonView

class FrontPageViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    ///showSearchBtnView
    @IBOutlet weak var showSearchBtnView: UIView! {
        didSet {
            showSearchBtnView.addRoundBorder()
        }
    }
    
    private lazy var searchView: HotelSearchView = {
        let view = HotelSearchView()
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    private var viewModel: FrontPageViewModel

    private var frontPageViewStatus: FrontPageViewStatus = .searchView {
        didSet {
            self.updateSearchViewState()
        }
    }
    
    init(viewModel: FrontPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: FrontPageViewController.className, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.delegate = self
        
        self.setupSearchView()
        self.setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        viewModel.fetchDataIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

// MARK: - Private

extension FrontPageViewController {
    
    /// 設定 Search View
    private func setupSearchView() {
        let searchTap = UITapGestureRecognizer(target: self, action: #selector(toggleSearchViewVisibility))
        self.showSearchBtnView.isUserInteractionEnabled = true
        self.showSearchBtnView.addGestureRecognizer(searchTap)
        
        view.addSubview(searchView)
        self.searchView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.searchView.topAnchor.constraint(equalTo: view.topAnchor),
            self.searchView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        self.updateSearchViewState()
    }
    
    /// 設定 TableView
    private func setupTableView() {
        // 註冊cell
        self.tableView.register(UINib(nibName: "FrontPageTableViewCell", bundle: nil), forCellReuseIdentifier: FrontPageTableViewCell.cellIdenifier)
        
        self.tableView.isSkeletonable = true
    }
    
    /// 更新 UI 狀態
    private func updateSearchViewState() {
        switch self.frontPageViewStatus {
        case .searchView:
            // viewModel.numberOfRows == 0 代表沒資料
            let hasData = viewModel.numberOfRows > 0
            self.searchView.show(canCancel: hasData)
            
        case .resultTableView:
            self.searchView.hide(force: true)
            self.startLoadingSkeleton()
        }
    }
    
    /// 執行 Skeleton 動畫邏輯
    private func startLoadingSkeleton() {
        // 顯示動畫
        self.tableView.showAnimatedGradientSkeleton()
        
        // 1 秒後關閉
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            self.tableView.stopSkeletonAnimation()
            self.view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
            
            // 滾動回頂部，確保使用者從第一筆看起
            if self.viewModel.numberOfRows > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    @objc private func toggleSearchViewVisibility() {
        self.searchView.show()
    }
}

//MARK: - TableView
// SkeletonTableViewDataSource change UITableViewDataSource
extension FrontPageViewController: SkeletonTableViewDataSource, UITableViewDelegate {
    // skeletonView
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return FrontPageTableViewCell.cellIdenifier
    }
    
    // show skeletonView
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FrontPageTableViewCell.cellIdenifier, for: indexPath) as! FrontPageTableViewCell
        
        let hotel = viewModel.hotel(at: indexPath.row)
        cell.configure(with: hotel)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let hotelDataModel = viewModel.filteredHotels[indexPath.row]
        let viewModel = HotelDetailsViewModel(hotel: hotelDataModel)
        let vc = HotelDetailsViewController(viewModel: viewModel)
        vc.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(vc, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.back))
    }
}

// MARK: - FrontPageViewModelDelegate

extension FrontPageViewController: FrontPageViewModelDelegate {

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
    
    func presentUpdateSuggestion(serverTime: String) {
        let message = "偵測到政府平臺有新的旅宿資料（\(serverTime)）\n是否前往「關於」頁面更新離線資料庫？"
        self.showAlertClosure(title: "更新提醒", message: message,
                              okBtn: "前往更新") {
            self.tabBarController?.selectedIndex = 3
        }
    }
}

//MARK: - FrontPageTableViewCellDelegate

extension FrontPageViewController: FrontPageTableViewCellDelegate {

    func cellDidTapPhone(_ hotel: Hotel) {
        // 撥打電話
        self.showAlertClosure(title: "通知", message: "將外撥電話至 \(hotel.name)", okBtn: "確定") {
            let phone = hotel.tel
            if let url = URL(string: "tel:\(phone)") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    self.view.showToast(text: "撥打失敗，請稍後再嘗試")
                }
            } else {
#if DEBUG
                print("連結錯誤")
#endif
            }
        }
    }
    
    func cellDidTapWebsite(_ hotel: Hotel) {
        let vc = OpenWKWebViewController.make(urlString: hotel.website,
                                              title: hotel.name)
        navigationController?.pushViewController(vc, animated: true)
    }

    func cellDidTapFavorite(_ hotel: Hotel) {
        RealmManager.shard?.toggleHotelFavorite(hotel)
    }
}

// MARK: - HotelSearchViewDelegate

extension FrontPageViewController: HotelSearchViewDelegate {
    
    func hotelSearchViewDidTapSearch(_ view: HotelSearchView, keyword: String) {
        // 執行搜尋並取得是否有結果
        let hasResults = self.viewModel.search(keyword: keyword)
        
        if hasResults {
            // 有資料
            self.frontPageViewStatus = .resultTableView
        } else {
            // 無資料
            self.view.showToast(text: "搜尋失敗，查無相關旅宿哦！")
             view.shake()
        }
    }
    
    func hotelSearchViewDidTapCancel(_ view: HotelSearchView) {
        // 如果目前畫面上本來就有資料（之前搜尋過），才允許回到 TableView
        if self.viewModel.numberOfRows > 0 {
            self.frontPageViewStatus = .resultTableView
        } else {
            // 如果連一次搜尋都還沒成功過，不允許取消顯示空狀態
            self.view.showToast(text: "請先輸入關鍵字搜尋")
        }
    }
}
