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
    
    lazy var viewModel: HotelViewModel = {
        return HotelViewModel()
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
            self.searchView.hide()
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
        return hotelDataModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return frontPageTableViewCell(on: tableView, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = HotelDetailsViewController(hotelDataModel: hotelDataModel[indexPath.row])
        vc.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(vc, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.back))
    }

    // MARK: Cell
    private func frontPageTableViewCell(on tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FrontPageTableViewCell.cellIdenifier, for: indexPath) as! FrontPageTableViewCell
        
        let dataModel = hotelDataModel[indexPath.row]
        
        configureCell(cell, with: dataModel)
        
        cell.collectionsBtn.tag = indexPath.row
        cell.collectionsBtn.addTarget(self, action: #selector(collectionsBtnAction(_:)), for: .touchUpInside)
        
        // 電話
        cell.phoneBtn.isHidden = isDataEmpty(dataModel.telephones[0])
        cell.phoneBtn.tag = indexPath.row
        cell.phoneBtn.addTarget(self, action: #selector(phoneBtnAction(_:)), for: .touchUpInside)
        
        // 官網
        cell.webBtn.isHidden = isDataEmpty(dataModel.websiteURL)
        cell.webBtn.tag = indexPath.row
        cell.webBtn.addTarget(self, action: #selector(webBtnAction(_:)), for: .touchUpInside)
        
        // 信箱
        cell.emailBtn.isHidden = isDataEmpty(dataModel.industryEmail)
        cell.emailBtn.tag = indexPath.row
        cell.emailBtn.addTarget(self, action: #selector(emailBtnAction(_:)), for: .touchUpInside)
        
        return cell
    }
    
    private func configureCell(_ cell: FrontPageTableViewCell, with dataModel: Hotels) {
        cell.nameLabel.text = dataModel.hotelName
        
        cell.hotelimageView.loadUrlImage(urlString: dataModel.images.first?.url ?? "") { result in
            switch result {
            case .success(let image):
                if let image = image {
                    cell.hotelimageView.image = image
                } else {
                    cell.hotelimageView.image = UIImage(named: "iconError")
                }
            case .failure(_):
                cell.hotelimageView.image = UIImage(named: "iconError")
            }
        }
        
        // 星級
        cell.gradeLabel.isHidden = isDataEmpty(dataModel.hotelStars)
        cell.gradeLabel.text = "☆級：\(dataModel.hotelStars)"
        
        cell.govLabel.text = dataModel.hotelID
        cell.descriptionLabel.text = dataModel.description
        
        // 價格
        let priceText = dataModel.lowestPrice != dataModel.ceilingPrice ? "\(dataModel.lowestPrice) ~ \(dataModel.ceilingPrice)" : "\(dataModel.ceilingPrice)"
        cell.priceLabel.text = "： \(priceText)"
        
        // 旅店類別
        if let hotelClass = dataModel.hotelClasses.first.flatMap(HotelClass.init(rawValue:)) {
            cell.hotleCalssLabel.text = "：\(hotelClass.description)"
        } else {
            cell.hotleCalssLabel.text = "旅店未提供"
        }
        
        let formattedAddress = String.formattedAddress(region: dataModel.city,
                                                       town: dataModel.town,
                                                       add: dataModel.streetAddress)
        cell.addLabel.text = formattedAddress
    }
    
    //MARK: Button標籤區
    // love
    @objc func collectionsBtnAction(_ sender: UIButton) {
        let index = sender.tag
        let hotelDataModel = hotelDataModel[index]
        
        RealmManager.shard?.addHotelDataModelToRealm(hotelDataModel)
    }
    
    // 撥打電話鈕
    @objc func phoneBtnAction(_ sender: UIButton) {
        let index = sender.tag
        let searchData = hotelDataModel[index]
        
        showAlertClosure(title: "通知", message: "將外撥電話至 \(searchData.hotelName)", okBtn: "確定") {
            let phone = searchData.telephones
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
// MARK: - HotelSearchViewDelegate

extension FrontPageViewController: HotelSearchViewDelegate {
    
    func hotelSearchViewDidTapSearch(_ view: HotelSearchView, keyword: String) {
        viewModel.search(keyword: keyword)
        // 搜尋後狀態切換為結果頁面
        self.frontPageViewStatus = .resultTableView
    }
    
    func hotelSearchViewDidTapCancel(_ view: HotelSearchView) {
        // 取消後回到結果頁面
        self.frontPageViewStatus = .resultTableView
    }
}
