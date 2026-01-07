//
//  AboutViewModel.swift
//  寶島旅社
//
//  Created by Eric Lin on 2026/1/6.
//  Copyright © 2026 Eric Lin. All rights reserved.
//

import Foundation

// MARK: - TableView RowModel
struct AboutViewRowModel {
    let type: AboutViewRowType
    let subtitle: String
    let isClickable: Bool
    var iconName: String? = nil
}

protocol AboutViewModelDelegate: AnyObject {
    func reloadData()
    func viewModelDidFail(_ error: Error)
    func onDownloadSuccess(isAlreadyLatest: Bool)
}

class AboutViewModel {
    
    private(set) var contents: [(section: AboutViewSectionType, rows: [AboutViewRowModel])] = []
    /// App 版本
    private let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    
    private(set) var syncState: DataSyncState = .checking
    
    private var serverUpdateTime: String?
    
    weak var delegate: AboutViewModelDelegate?
    
    init() {
        // 初始化 UI
        self.buildViewModel()
        
        // 判斷是否需要檢查
        if HotelDataManager.shared.totalCount == 0 {
            self.syncState = .needUpdate
        } else {
            self.syncState = .upToDate
        }
        
        // 背景執行版本檢查
        self.checkServerVersion()
    }
    
    func buildViewModel() {
        self.contents.removeAll()
        
        // 取得本地儲存的日期與筆數
        let localDate = HotelDataManager.shared.lastUpdateDate.formatDateToYearMonthDay() ?? "尚未下載"
        let countString = HotelDataManager.shared.totalCount > 0 ? "\(HotelDataManager.shared.totalCount) 間" : "無資料"
        
        // 關於區塊
        let aboutRows = [
            AboutViewRowModel(type: .appVersion, subtitle: self.appVersion, isClickable: false),
            AboutViewRowModel(type: .apiSource, subtitle: "政府開放平臺", isClickable: true),
            AboutViewRowModel(type: .updateDate, subtitle: localDate, isClickable: false),
            AboutViewRowModel(type: .hotelCount, subtitle: countString, isClickable: false)
        ]
        self.contents.append((.about, aboutRows))
        
        // 設定區塊
        var downloadSubtitle: String
        var iconName: String
        
        switch syncState {
        case .checking:
            downloadSubtitle = "檢查更新中..."
            iconName = "arrow.trianglehead.2.clockwise.rotate.90.icloud.fill"
        case .upToDate:
            downloadSubtitle = "已是最新版本"
            iconName = "checkmark.icloud.fill"
        case .needUpdate:
            let hasData = HotelDataManager.shared.totalCount > 0
            downloadSubtitle = hasData ? "有新的版本可更新" : "立即下載離線資料"
            iconName = hasData ? "arrow.clockwise.icloud.fill" : "icloud.and.arrow.down.fill"
        case .error:
            downloadSubtitle = "暫時無法檢查更新"
            iconName = "exclamationmark.icloud.fill"
        }
        
        let setupRows = [
            AboutViewRowModel(type: .downloadData,
                              subtitle: downloadSubtitle,
                              isClickable: true,
                              iconName: iconName)
        ]
        
        self.contents.append((.setup, setupRows))
    }
        
    func checkServerVersion() {
        APIManager.shared.sendGet(endpoint: APIInfo.hotelList, responseType: HotelListResponse.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let serverTime = response.xmlHead.updatetime
                let localTime = HotelDataManager.shared.lastUpdateDate
                
                // 比對：只要 server 時間不等於本地存的時間，就是 needUpdate
                self.syncState = (serverTime == localTime) ? .upToDate : .needUpdate
            case .failure:
                self.syncState = .error
            }
            
            self.buildViewModel()
            self.delegate?.reloadData()
        }
    }
    
    func fetchLatestData() {
        // 如果狀態已經是最新，直接回傳成功
        if syncState == .upToDate {
            self.delegate?.onDownloadSuccess(isAlreadyLatest: true)
            return
        }
        
        LoadingPageView.shard.show()
        APIManager.shared.sendGet(endpoint: APIInfo.hotelList, responseType: HotelListResponse.self) { [weak self] result in
            guard let self = self else { return }
            LoadingPageView.shard.dismiss()
            switch result {
            case .success(let response):
                let hotels = response.xmlHead.infos.info
                HotelDataManager.shared.saveHotelsToDisk(hotels, updateTime: response.xmlHead.updatetime)
                
                self.syncState = .upToDate
                self.buildViewModel()
                self.delegate?.reloadData()
                self.delegate?.onDownloadSuccess(isAlreadyLatest: false) // 🆕 通知更新成功
                
            case .failure(let error):
                self.delegate?.viewModelDidFail(error)
            }
        }
    }
}

// MARK: - TableView ViewModel Getter
extension AboutViewModel {
    func numberOfSections() -> Int {
        return self.contents.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        return self.contents[section].rows.count
    }
    
    func rowModel(at indexPath: IndexPath) -> AboutViewRowModel {
        return self.contents[indexPath.section].rows[indexPath.row]
    }
}

extension AboutViewModel {
    
    /// 呼叫 API 檢查伺服器資料是否有更新
    private func checkForUpdates() {
        APIManager.shared.sendGet(endpoint: APIInfo.hotelList,
                                  responseType: HotelListResponse.self) { [weak self] result in
            guard let self = self else { return }
            
            HotelDataManager.shared.markAsUpdatedNow()
            
            switch result {
            case .success(let response):
                let serverUpdateTime = response.xmlHead.updatetime
                let localUpdateTime = HotelDataManager.shared.lastUpdateDate
                
                // 比對時間戳記
                if serverUpdateTime != localUpdateTime {
                    print("💡 偵測到伺服器有新資料：\(serverUpdateTime)")
                    let hotels = response.xmlHead.infos.info
                    
                    HotelDataManager.shared.saveHotelsToDisk(hotels, updateTime: serverUpdateTime)
                    self.delegate?.reloadData()
                }
            case .failure:
                break
            }
        }
    }
}
