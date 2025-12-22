//
//  HotelDetailViewController.swift
//  寶島旅社
//
//  Created by Eric Lin on 2022/10/20.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit

class HotelDetailsViewController: UIViewController {
    enum HotelDetailsType: Int {
        case hotelImage = 0
        case hotelDetails
        case hotelDescription
        case hotelExtra
        case hotelMap
    }
    
    struct DetailImageData {
        let imageURL: String
        let title: String
    }
    
    private var hotelDataModel: Hotel
    private var collectionImageDataModel: [DetailImageData] = []

    private let useCells: [UITableViewCell.Type] = [HotelDetailCollectionTableViewCell.self,
                                                    MapTableViewCell.self,
                                                    DescriptionTableViewCell.self,
                                                    HotelExtraDetailsTableViewCell.self,
                                                    HotelDetailsTableViewCell.self]
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(hotelDataModel: Hotel) {
        self.hotelDataModel = hotelDataModel
        super.init(nibName: nil, bundle: nil)
    }
    
    //MARK: - UI
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    //MARK: - setup
    private func setupViews() {
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
        
        // 註冊cell
        useCells.forEach {
            tableView.register(UINib(nibName: $0.storyboardIdentifier,
                                     bundle: Bundle.messageCoreBundle),
                               forCellReuseIdentifier: $0.storyboardIdentifier)
        }
    }
    
    private func setupConstraint() {
        let topSafeArea = view.safeAreaLayoutGuide.topAnchor
        let leftSafeArea = view.safeAreaLayoutGuide.leftAnchor
        let rightSafeArea = view.safeAreaLayoutGuide.rightAnchor
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topSafeArea),
            tableView.leftAnchor.constraint(equalTo: leftSafeArea),
            tableView.rightAnchor.constraint(equalTo: rightSafeArea),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraint()
        
        getCollectionViewDataModel()
     
        navigationItem.title = hotelDataModel.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "phone.circle"), style: .plain, target: self, action: #selector(callPhoneBtn))
    }
    
    private func getCollectionViewDataModel() {
        collectionImageDataModel = hotelDataModel.images.compactMap { imageModel in
            
            return DetailImageData(imageURL: imageModel.url,
                                   title: imageModel.description)
        }
    }
    
   @objc func callPhoneBtn() {
        showAlertClosure(title: "通知", message: "將外撥電話至 \(hotelDataModel.name)", okBtn: "確定") {
            let phone = self.hotelDataModel.tel
            if let url = URL(string: "tel:\(phone)") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    self.showAlert(title: "通知", message: "撥打失敗，請稍後再嘗試")
                }
            } else {
                #if DEBUG
                print("連結錯誤")
                #endif
            }
        }
    }
    
    @objc func getOpenWebView() {
        let vc = OpenWKWebViewController.make(urlString: hotelDataModel.website,
                                              title: hotelDataModel.name)
        vc.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(vc, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.back))
    }
    
    @objc func addHotelDataModelToRealm() {
        RealmManager.shard?.addHotelToRealm(hotelDataModel)
    }
}

//MARK: - TableView
extension HotelDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return useCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = HotelDetailsType(rawValue: indexPath.row) else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
            return cell
        }
        
        switch type {
        case .hotelImage:
            return openDetailCollectionTableViewCell(on: tableView, at: indexPath)
        case .hotelDetails:
            return openHotelDetailCell(on: tableView, at: indexPath)
        case .hotelDescription:
            return openDescriptionTableViewCell(on: tableView, at: indexPath)
        case .hotelExtra:
            return openHotelExtraDetailCell(on: tableView, at: indexPath)
        case .hotelMap:
            return openMapTableViewCell(on: tableView, at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let type = HotelDetailsType(rawValue: indexPath.row) else {
            return
        }
        
        switch type {
        case .hotelMap:
            let vc = HotelDetailsMapViewController.make(hotelData: hotelDataModel)

            self.navigationController?.pushViewController(vc, animated: true)
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.back))
        default:
            break
        }
    }
    
    //MARK: Cell
    // collection
    func openDetailCollectionTableViewCell(on tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelDetailCollectionTableViewCell.self), for: indexPath) as! HotelDetailCollectionTableViewCell
        cell.collectionView.dataSource = self
        cell.collectionView.delegate = self
        
        cell.pageControl.numberOfPages = collectionImageDataModel.count
        // 分頁模式
        cell.collectionView.isPagingEnabled = true
        cell.collectionView.register(ImageDataCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: ImageDataCollectionViewCell.self))
        
        return cell
    }
    
    // 說明介紹
    func openDescriptionTableViewCell(on tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DescriptionTableViewCell.self), for: indexPath) as! DescriptionTableViewCell
        
        cell.configure(dataModel: hotelDataModel)
        
        return cell
    }
    
    // 旅店說明
    func openHotelDetailCell(on tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelDetailsTableViewCell.self), for: indexPath) as! HotelDetailsTableViewCell
        
        cell.configure(hotel: hotelDataModel, delegate: self)
    
        return cell
    }
    
    // 額外細節說明
    func openHotelExtraDetailCell(on tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HotelExtraDetailsTableViewCell.self), for: indexPath) as! HotelExtraDetailsTableViewCell
        
        cell.configure(dataModel: hotelDataModel)
        
        return cell
    }
    
    // MAP
    func openMapTableViewCell(on tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MapTableViewCell.self), for: indexPath) as! MapTableViewCell
        
        cell.configure(dataModel: hotelDataModel)
        
        return cell
    }
}

//MARK: - Collection
extension HotelDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionImageDataModel.count {
        case 0:
            return 1 //show error imageView
        default:
            return collectionImageDataModel.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageDataCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageDataCollectionViewCell.self), for: indexPath) as! ImageDataCollectionViewCell
        
        if indexPath.row < collectionImageDataModel.count {
            let imageData = collectionImageDataModel[indexPath.row]
            cell.configure(with: imageData.imageURL, title: imageData.title)
        } else {
            cell.configure()
        }
        return cell
    }
    
    // cell的間距。如設定isPagingEnabled(換頁模式)的話，要設定為0
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // cell自適應為CollectionView的Layout
    // Estimate Size記得要設定為None，不然無法work
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width,
                      height: collectionView.bounds.height)
    }
    
    // CollectionView 繼承自 ScrollView。可直接使用
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width + 0.6
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? HotelDetailCollectionTableViewCell
        // 這裡要用as?, as!實機會偶發閃退問題
        cell?.pageControl.currentPage = Int(page)
    }
}

//MARK: - HotelDetailsTableViewCellDelegate
extension HotelDetailsViewController: HotelDetailsTableViewCellDelegate {
    func addHotelDataModelToRealm(for cell: HotelDetailsTableViewCell) {
        self.addHotelDataModelToRealm()
    }
    
    func webLabelTapped(for cell: HotelDetailsTableViewCell) {
        self.getOpenWebView()
    }
}
