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
    enum FrontPageViewStatus {
        case searchView
        case resultTableView
    }
    
    static func makeToHome() -> FrontPageViewController {
        let storyboard = UIStoryboard(name: "FrontPageStoryboard", bundle: nil)
        let vc: FrontPageViewController = storyboard.instantiateViewController(withIdentifier: "FrontPageIentity") as! FrontPageViewController
        return vc
    }
    
    //MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topButtonView: UIView!
    
    ///showSearchBtnView
    @IBOutlet weak var showSearchBtnView: UIView! {
        didSet {
            showSearchBtnView.addRoundBorder()
        }
    }
    ///showMapSearchView
    @IBOutlet weak var showMapBtnView: UIView! {
        didSet {
            showMapBtnView.addRoundBorder()
        }
    }
    
    private lazy var searchView: HotelSearchView = {
        let view = HotelSearchView()
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    lazy var viewModel: FrontPageViewModel = {
        return FrontPageViewModel()
    }()

    private var frontPageViewStatus: FrontPageViewStatus = .searchView {
        didSet {
            self.updateSearchViewState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // 註冊cell
        tableView.register(UINib(nibName: "FrontPageTableViewCell", bundle: nil), forCellReuseIdentifier: FrontPageTableViewCell.cellIdenifier)
        
        viewModel.delegate = self
        viewModel.fetchHotels()
        
        self.setupSearchView()
   
        // 地圖手勢
        let mapTap = UITapGestureRecognizer(target: self, action: #selector((showMapView)))
        self.showMapBtnView.isUserInteractionEnabled = true
        self.showMapBtnView.addGestureRecognizer(mapTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func showMapView() {
        // TODO: 替換資料結構
//        let vc = MapSearchViewController.make(dataModel: viewModel.allHotels)
//        vc.hidesBottomBarWhenPushed = true
//        
//        self.navigationController?.pushViewController(vc, animated: true)
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.back))
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
            searchView.topAnchor.constraint(equalTo: view.topAnchor),
            searchView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        self.updateSearchViewState()
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
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return frontPageTableViewCell(on: tableView, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let vc = HotelDetailsViewController(hotelDataModel: hotelDataModel[indexPath.row])
//        vc.hidesBottomBarWhenPushed = true
//        
//        self.navigationController?.pushViewController(vc, animated: true)
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.back))
    }

    // MARK: Cell
    private func frontPageTableViewCell(on tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FrontPageTableViewCell.cellIdenifier, for: indexPath) as! FrontPageTableViewCell
        
        let hotel = viewModel.hotel(at: indexPath.row)
        cell.configure(with: hotel)
        cell.delegate = self
        
        return cell
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
        // TODO: 待調整 RealmManager 資料結構
//        RealmManager.shard?.addHotelDataModelToRealm(hotel)
    }
}

// MARK: - HotelSearchViewDelegate

extension FrontPageViewController: HotelSearchViewDelegate {
    
    func hotelSearchViewDidTapSearch(_ view: HotelSearchView, keyword: String) {
        // 執行搜尋並取得是否有結果
        let hasResults = viewModel.search(keyword: keyword)
        
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
        if viewModel.numberOfRows > 0 {
            self.frontPageViewStatus = .resultTableView
        } else {
            // 如果連一次搜尋都還沒成功過，通常不允許取消，或者顯示空狀態
            self.view.showToast(text: "請先輸入關鍵字搜尋")
        }
    }
}
