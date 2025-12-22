//
//  AboutViewController.swift
//  寶島旅社
//
//  Created by Eric Lin on 2022/10/14.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit

struct APIDataStorage {
    static var hotelDataBase: HotelListResponse?
}

enum AboutViewControllerType: Int, CaseIterable {
    // Section
    case about = 0
    case setup = 1
    
    var sectionTitle: String {
        switch self {
        case .about:
            return "關於"
        case .setup:
            return "設定"
        }
    }
    
    enum CellSubtitle {
        case appVersion
        case apiDataSource
        case dataUpdateDate
        case totalHotelCount
        case underDesign
        
        var rowTitle: String {
            switch self {
            case .appVersion:
                return "APP版本"
            case .apiDataSource:
                return "資料來源"
            case .dataUpdateDate:
                return "資料更新日期"
            case .totalHotelCount:
                return "目前旅店總筆數"
            case .underDesign:
                return "動工中"
            }
        }
    }
    
    var cellDataArray: [CellSubtitle] {
        switch self {
        case .about:
            return [.appVersion, .apiDataSource, .dataUpdateDate, .totalHotelCount]
        case .setup:
            return [.underDesign]
        }
    }
}

class AboutViewController: BaseViewController {
    static func make() -> AboutViewController {
        let storyboard = UIStoryboard(name: "AboutStoryboard", bundle: nil)
        let vc: AboutViewController = storyboard.instantiateViewController(withIdentifier: "AboutIdentifier") as! AboutViewController
        
        return vc
    }
    
    @IBOutlet weak var kanaheiImageView: UIImageView!
    
    private var allHotels: [Hotel] {
        return HotelDataManager.shared.allHotels
    }
    
    private let viewControllerTypes: [AboutViewControllerType] = [.about, .setup]
    private let useCells: [UITableViewCell.Type] = [PersonalSettingsLanguageTableViewCell.self]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "關於"
        kanaheiImageView.loadGif(name: GifImageNames.shared.aboutImageName)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // 註冊cell
        useCells.forEach {
            tableView.register($0.self, forCellReuseIdentifier: $0.storyboardIdentifier)
        }
    }
    
    @objc func openWKUrl() {
        let vc = OpenWKWebViewController.make(urlString: "https://data.gov.tw/dataset/7780", title: "政府資料開放平臺")
        vc.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(vc, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.back))
    }
}

//MARK: - TableView
extension AboutViewController: UITableViewDataSource, UITableViewDelegate {
    // section
    func numberOfSections(in tableView: UITableView) -> Int {
        return AboutViewControllerType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionType = AboutViewControllerType(rawValue: section) else {
            return nil
        }
        
        let headerView = SettingsTableViewHeaderFooterView(title: sectionType.sectionTitle, reuseIdentifier: SettingsTableViewHeaderFooterView.reuseIdentifier)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SettingsTableViewHeaderFooterView.height
    }
    
    // row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = AboutViewControllerType(rawValue: section) else {
            return 0
        }
        return sectionType.cellDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PersonalSettingsLanguageTableViewCell.storyboardIdentifier, for: indexPath) as? PersonalSettingsLanguageTableViewCell else {
            return UITableViewCell()
        }
        
        let sectionType = viewControllerTypes[indexPath.section]
        
        switch sectionType {
        case .about:
            configureCellForAboutSection(indexPath: indexPath, cell: cell)
        case .setup:
            configureCellForSetupSection(indexPath: indexPath, cell: cell)
        }
        
        return cell
    }
    
    private func configureCellForAboutSection(indexPath: IndexPath, cell: PersonalSettingsLanguageTableViewCell) {
        let rowDataTitle = viewControllerTypes[indexPath.section].cellDataArray[indexPath.row]
        
        switch rowDataTitle {
        case .appVersion:
            // 版本
            let versions = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
            let subtitle = "\(versions ?? "")"
            cell.configure(title: rowDataTitle.rowTitle, subtitle: subtitle)
            
        case .apiDataSource:
            // 資料來源
            let subtitle = "政府資料開放平臺"
            let tap = UITapGestureRecognizer(target: self, action: #selector(openWKUrl))
            cell.configure(title: rowDataTitle.rowTitle, subtitle: subtitle, tap: tap)
            
        case .dataUpdateDate:
            // 資料更新日期
            let dateTimeString = APIDataStorage.hotelDataBase?.xmlHead.updatetime
            if let formattedDateString = dateTimeString?.formatDateToYearMonthDay() {
                cell.configure(title: rowDataTitle.rowTitle, subtitle: formattedDateString)
            }
        case .totalHotelCount:
            // 旅店總筆數
            if let subtitle = APIDataStorage.hotelDataBase?.xmlHead.infos.info.count {
                cell.configure(title: rowDataTitle.rowTitle, subtitle: "\(subtitle) 間")
            }
        default:
            break
        }
    }

    private func configureCellForSetupSection(indexPath: IndexPath, cell: PersonalSettingsLanguageTableViewCell) {
        let rowDataTitle = viewControllerTypes[indexPath.section].cellDataArray[indexPath.row]
        
        switch rowDataTitle {
        case .underDesign:
            let subtitle = "我還在想要做什麼"
            cell.configure(title: rowDataTitle.rowTitle, subtitle: subtitle)
        default:
            break
        }
    }
}
