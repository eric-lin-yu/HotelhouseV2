//
//  FrontPageViewModel.swift
//  寶島旅社
//
//  Created by wistronits on 2025/12/18.
//  Copyright © 2025 Eric Lin. All rights reserved.
//

import Foundation

protocol FrontPageViewModelDelegate: AnyObject {
    func reloadData()
    func viewModelDidFail(_ error: Error)
}

class FrontPageViewModel {
    
    weak var delegate: FrontPageViewModelDelegate?
    
    private(set) var allHotels: [Hotel] = []
    private(set) var filteredHotels: [Hotel] = []
    
    var numberOfRows: Int {
        filteredHotels.count
    }
    
    func hotel(at index: Int) -> Hotel {
        filteredHotels[index]
    }
    
    func fetchDataIfNeeded() {
        // 載入本地資料
        if !HotelDataManager.shared.allHotels.isEmpty {
            self.allHotels = HotelDataManager.shared.allHotels
            self.delegate?.reloadData()
            
            // 今天是否更新過資料
            if !HotelDataManager.shared.isUpdatedToday {
                self.checkForUpdates()
            }
        } else {
            // 無資料強制下載
            self.fetchHotels()
        }
    }

    /// 執行搜尋並回傳是否有結果
    func search(keyword: String) -> Bool {
        let normalizedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "台", with: "臺")
        
        if normalizedKeyword.isEmpty {
            self.filteredHotels = []
            return false
        }
        
        // 執行過濾
        let results = allHotels.filter { $0.matches(keyword: normalizedKeyword) }
        
        if results.isEmpty {
            return false
        } else {
            self.filteredHotels = results
            self.delegate?.reloadData()
            return true
        }
    }
    
    // MARK: - API
    /// 呼叫 API 取得旅店資料
    private func fetchHotels() {
        LoadingPageView.shard.show()
        APIManager.shared.sendGet(endpoint: APIInfo.hotelList,
                                  responseType: HotelListResponse.self) { [weak self] result in
            guard let self else { return }
            LoadingPageView.shard.dismiss()
            switch result {
            case .success(let response):
                let hotels = response.xmlHead.infos.info
                let updateTime = response.xmlHead.updatetime
                
                self.allHotels = hotels
                
                // 儲存資料與時間
                HotelDataManager.shared.markAsUpdatedNow()
                HotelDataManager.shared.saveHotelsToDisk(hotels, updateTime: updateTime)
            case .failure(let error):
                self.delegate?.viewModelDidFail(error)
            }
        }
    }
    
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
                    self.allHotels = hotels
                    HotelDataManager.shared.saveHotelsToDisk(hotels, updateTime: serverUpdateTime)
                    self.delegate?.reloadData()
                }
            case .failure:
                break
            }
        }
    }
}
