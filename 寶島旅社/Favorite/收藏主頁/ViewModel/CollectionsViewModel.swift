//
//  CollectionsViewModel.swift
//  寶島旅社
//
//  Created by Eric Lin on 2024/7/21.
//  Copyright © 2024 Eric Lin. All rights reserved.
//

import Foundation

protocol CollectionsViewModelDelegate: AnyObject {
    /// 當資料更新時通知 View 刷新介面
    func reloadData()
    /// 當資料讀取失敗時通知 View 顯示錯誤
    func viewModelDidFail()
}

class CollectionsViewModel {
    
    weak var delegate: CollectionsViewModelDelegate?
    
    /// 原始的旅店數據
    private(set) var allHotels: [Hotel] = []
    /// 搜尋過濾後的旅店數據
    private var filteredHotels: [Hotel] = []
    /// 當前的搜尋狀態
    private var isSearching = false
    
    /// 依據城市名稱分組後的資料字典 [城市名稱: [旅店陣列]]
    private var groupedHotels: [String: [Hotel]] = [:]
    /// 排序後的城市名稱清單（用於 Section 標題）
    private var cityNames: [String] = []
    /// 紀錄目前縮合的 Section 集合（儲存城市名稱）
    private var collapsedSections = Set<String>()
    
    /// 當前應使用的資料源
    private var dataSource: [Hotel] {
        self.isSearching ? self.filteredHotels : self.allHotels
    }
    
    /// 從 Realm 加載旅店數據並進行初始化分組
    func loadHotels() {
        guard let realmData = RealmManager.shard?.getHotelsFromRealm() else {
            self.delegate?.viewModelDidFail()
            return
        }
        self.allHotels = realmData
        updateUIState()
    }
    
    /// 執行關鍵字搜尋
    /// - Parameter keyword: 搜尋字串
    /// - Returns: 搜尋到的總數
    @discardableResult
    func search(keyword: String) -> Int {
        let normalizedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "台", with: "臺")
        
        self.isSearching = !normalizedKeyword.isEmpty
        
        if self.isSearching {
            self.filteredHotels = self.allHotels.filter {
                $0.matches(keyword: normalizedKeyword)
            }
            self.collapsedSections.removeAll() // 搜尋時自動展開
        } else {
            self.filteredHotels = []
        }
        
        self.updateUIState()
        return self.dataSource.count
    }
    
    /// 切換指定 Section 的縮合或展開狀態
    /// - Parameter section: TableView 的 Section 索引
    func toggleSection(_ section: Int) {
        let city = self.cityNames[section]
        if self.collapsedSections.contains(city) {
            self.collapsedSections.remove(city)
        } else {
            self.collapsedSections.insert(city)
        }
    }
}

// MARK: - TableView Data Provider

extension CollectionsViewModel {
    
    /// 取得 Section 數量
    func numberOfSections() -> Int {
        self.cityNames.count
    }
    
    /// 取得指定 Section 的資料列數
    func numberOfRows(in section: Int) -> Int {
        if isSectionCollapsed(section) { return 0 }
        return self.groupedHotels[self.cityNames[section]]?.count ?? 0
    }
    
    /// 取得 Section 標題
    func titleForSection(_ section: Int) -> String {
        self.cityNames[section]
    }
    
    /// 檢查特定 Section 是否為縮合狀態
    func isSectionCollapsed(_ section: Int) -> Bool {
        self.collapsedSections.contains(self.cityNames[section])
    }
    
    /// 取得指定位置的旅店資料
    func hotel(at indexPath: IndexPath) -> Hotel? {
        guard indexPath.section < self.cityNames.count else { return nil }
        let city = self.cityNames[indexPath.section]
        return self.groupedHotels[city]?[indexPath.row]
    }
}

// MARK: - Private

extension CollectionsViewModel {
    
    /// 更新內部分組資料並通知 UI 刷新
    private func updateUIState() {
        self.groupAndSortHotelsByCity()
        self.delegate?.reloadData()
    }
    
    /// 處理分組邏輯與地理位置排序（北到南）
    private func groupAndSortHotelsByCity() {
        // 分組
        self.groupedHotels = Dictionary(grouping: self.dataSource, by: { $0.region ?? "其他" })
        
        // 定義地理順序權重
        let cityOrder = self.getCityOrder()
        
        // 排序城市名
        self.cityNames = self.groupedHotels.keys.sorted { (a, b) in
            let wA = cityOrder[a] ?? 99
            let wB = cityOrder[b] ?? 99
            return wA != wB ? wA < wB : a < b
        }
    }
    
    /// 取得台灣縣市地理位置排序表（北到南）
    private func getCityOrder() -> [String: Int] {
        return [
            "基隆市": 1, "臺北市": 2, "台北市": 3, "新北市": 4, "桃園市": 5,
            "新竹縣": 6, "新竹市": 7, "苗栗縣": 8, "臺中市": 9, "台中市": 10,
            "彰化縣": 11, "南投縣": 12, "雲林縣": 13, "嘉義縣": 14, "嘉義市": 15,
            "臺南市": 16, "台南市": 17, "高雄市": 18, "屏東縣": 19, "宜蘭縣": 20,
            "花蓮縣": 21, "臺東縣": 22, "台東縣": 23, "澎湖縣": 24, "金門縣": 25, "連江縣": 26
        ]
    }
}
