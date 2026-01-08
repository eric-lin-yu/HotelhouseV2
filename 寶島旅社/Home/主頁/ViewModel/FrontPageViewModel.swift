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
    func presentUpdateSuggestion(serverTime: String)
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
        // 版本檢查
        if !HotelDataManager.shared.isUpdatedToday {
            HotelDataManager.shared.checkVersion { [weak self] result in
                if case .needUpdate(let serverTime) = result {
                    self?.delegate?.presentUpdateSuggestion(serverTime: serverTime)
                }
            }
        }
        
        // 載入本地資料流程
        if !HotelDataManager.shared.allHotels.isEmpty {
            self.allHotels = HotelDataManager.shared.allHotels
            self.delegate?.reloadData()
        } else {
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
                
                let updateTime = response.xmlHead.updatetime
                self.allHotels = response.xmlHead.infos.info
                // 同步儲存到本地
                HotelDataManager.shared.saveHotelsToDisk(self.allHotels,
                                                         updateTime: updateTime)
                self.delegate?.reloadData()
            case .failure(let error):
                self.delegate?.viewModelDidFail(error)
            }
        }
    }
}
