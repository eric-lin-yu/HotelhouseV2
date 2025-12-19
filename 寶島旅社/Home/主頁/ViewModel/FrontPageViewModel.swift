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
    
    func fetchHotels() {
        LoadingPageView.shard.show()
        APIManager.shared.sendGet(endpoint: APIInfo.hotelList,
                                  responseType: HotelListResponse.self) { [weak self] result in
            guard let self else { return }
            LoadingPageView.shard.dismiss()
            switch result {
            case .success(let response):
                self.allHotels = response.xmlHead.infos.info
                self.delegate?.reloadData()
                
            case .failure(let error):
                self.delegate?.viewModelDidFail(error)
            }
        }
    }
    
    /// 執行搜尋並回傳是否有結果
    func search(keyword: String) -> Bool {
        let normalizedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "台", with: "臺")
        
        if normalizedKeyword.isEmpty {
            self.filteredHotels = [] // 或者根據需求決定是否清空
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
}
