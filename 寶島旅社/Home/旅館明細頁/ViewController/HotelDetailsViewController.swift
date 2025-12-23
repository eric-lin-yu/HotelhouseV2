//
//  HotelDetailViewController.swift
//  寶島旅社
//
//  Created by Eric Lin on 2022/10/20.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit

class HotelDetailsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: HotelDetailsViewModel
    
    init(viewModel: HotelDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: HotelDetailsViewController.className, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = viewModel.hotelName
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "phone.circle"), style: .plain, target: self, action: #selector(callPhoneBtn))
        
        self.setupUI()
    }
    
    @objc func callPhoneBtn() {
        self.showAlertClosure(title: "通知", message: "將外撥電話至 \(viewModel.hotelModel.name)", okBtn: "確定") {
            let phone = self.viewModel.hotelModel.tel
            if let url = URL(string: "tel:\(phone)") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    self.showAlert(title: "通知", message: "撥打失敗，請稍後再嘗試")
                }
            }
        }
    }
    
    @objc func getOpenWebView() {
        let vc = OpenWKWebViewController.make(urlString: viewModel.hotelModel.website,
                                              title: viewModel.hotelModel.name)
        vc.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(vc, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.back))
    }
}

//MARK: - Private
extension HotelDetailsViewController {
    
    private func setupUI() {
        // 註冊 Cell
        let useCells: [UITableViewCell.Type] = [
            HotelDetailCollectionTableViewCell.self,
            HotelMapTableViewCell.self,
            HotelDescriptionTableViewCell.self,
            HotelExtraDetailsTableViewCell.self,
            HotelDetailsTableViewCell.self
        ]
        
        useCells.forEach {
            tableView.register(UINib(nibName: $0.storyboardIdentifier, bundle: Bundle.messageCoreBundle), forCellReuseIdentifier: $0.storyboardIdentifier)
        }
    }
}

//MARK: - TableView

extension HotelDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowModel(at: section)?.cellModel.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowModel = viewModel.rowModel(at: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch rowModel.sectionType {
        case .hotelImage:
            let cell = tableView.dequeueReusableCell(withIdentifier: HotelDetailCollectionTableViewCell.storyboardIdentifier, for: indexPath) as! HotelDetailCollectionTableViewCell
            
            if let images = rowModel.cellModel.first as? [HotelImage] {
                cell.configure(with: images)
            }
            return cell
            
        case .hotelDetails:
            let cell = tableView.dequeueReusableCell(withIdentifier: HotelDetailsTableViewCell.storyboardIdentifier, for: indexPath) as! HotelDetailsTableViewCell
            cell.configure(hotel: viewModel.hotelModel, delegate: self)
            return cell
            
        case .hotelDescription:
            let cell = tableView.dequeueReusableCell(withIdentifier: HotelDescriptionTableViewCell.storyboardIdentifier, for: indexPath) as! HotelDescriptionTableViewCell
            cell.configure(dataModel: viewModel.hotelModel)
            return cell
            
        case .hotelExtra:
            let cell = tableView.dequeueReusableCell(withIdentifier: HotelExtraDetailsTableViewCell.storyboardIdentifier, for: indexPath) as! HotelExtraDetailsTableViewCell
            cell.configure(dataModel: viewModel.hotelModel)
            return cell
            
        case .hotelMap:
            let cell = tableView.dequeueReusableCell(withIdentifier: HotelMapTableViewCell.storyboardIdentifier, for: indexPath) as! HotelMapTableViewCell
            cell.configure(dataModel: viewModel.hotelModel)
            return cell
        }
    }
}

//MARK: - HotelDetailsTableViewCellDelegate
extension HotelDetailsViewController: HotelDetailsTableViewCellDelegate {
    
    /// 點擊收藏按鈕
    func addHotelDataModelToRealm() {
        RealmManager.shard?.addHotelToRealm(viewModel.hotelModel)
    }
    
    /// 點擊 web
    func webLabelTapped() {
        self.getOpenWebView()
    }
}
