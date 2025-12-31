//
//  CollectionsViewModel.swift
//  寶島旅社
//
//  Created by Eric Lin on 2024/7/21.
//  Copyright © 2024 Eric Lin. All rights reserved.
//

import Foundation
import MapKit

/// Segmented Control 的選項，用於控制列表和地圖視圖
enum SegmentedControlOption: Int {
    case list = 0   // 列表模式
    case map = 1    // 地圖模式
}

class CollectionsViewModel {
    
    /// 儲存所有的酒店數據模型
    private var hotelDataModel: [Hotel] = []
    /// 依據城市名稱將酒店分組
    private var groupedHotels: [String: [Hotel]] = [:]
    /// 存儲城市名稱的陣列
    private var cityNames: [String] = []
    
    /// 當酒店數據加載完成後的回調
    var onHotelsLoaded: (() -> Void)?
    /// 當加載數據出現錯誤時的回調
    var onError: ((Error) -> Void)?
    
    // MARK: - Public Methods
    
    /// 加載酒店數據，並將其分組和排序
    func loadHotels() {
        LoadingPageView.shard.show()
        if let realmDataModels = RealmManager.shard?.getHotelsFromRealm() {
            self.hotelDataModel = realmDataModels
            self.groupAndSortHotelsByCity()
    
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                LoadingPageView.shard.dismiss()
                self.onHotelsLoaded?()
            }
        }
    }
    
    /// 獲取城市數量，對應於表格的 section 數量
    /// - Returns: 城市數量
    func numberOfSections() -> Int {
        return self.cityNames.count
    }
    
    /// 獲取指定城市（section）中的酒店數量
    /// - Parameter section: 城市對應的 section
    /// - Returns: 酒店數量
    func numberOfRows(in section: Int) -> Int {
        guard section < self.cityNames.count else {
            return 0
        }
        
        let cityName = self.cityNames[section]
        return self.groupedHotels[cityName]?.count ?? 0
    }
    
    /// 獲取指定位置（indexPath）的酒店數據
    /// - Parameter indexPath: 位置對應的 indexPath
    /// - Returns: 酒店數據模型
    func hotel(at indexPath: IndexPath) -> Hotel? {
        guard indexPath.section < self.cityNames.count else {
            return nil
        }
        
        let cityName = self.cityNames[indexPath.section]
        return self.groupedHotels[cityName]?[indexPath.row]
    }
    
    /// 獲取所有酒店的地圖標註信息
    /// - Returns: 酒店標註陣列
    func getHotelAnnotations() -> [HotelAnnotation] {
        return hotelDataModel.compactMap { hotel in
            let latitude = Double(hotel.py)
            let longitude = Double(hotel.px)
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            return HotelAnnotation(hotel: hotel, coordinate: coordinate)
        }
    }
}

// MARK: - Private Methods

extension CollectionsViewModel {
    
    /// 將酒店數據按城市分組並排序
    private func groupAndSortHotelsByCity() {
        self.groupedHotels = [:]
//        
//        for hotel in self.hotelDataModel {
//            let city = hotel.city
//            if var cityHotels = self.groupedHotels[city] {
//                cityHotels.append(hotel)
//                self.groupedHotels[city] = cityHotels
//            } else {
//                self.groupedHotels[city] = [hotel]
//            }
//        }
//        
//        let sortedGroupedHotels = self.groupedHotels.sorted { $0.key < $1.key }
//        let sortedGroupedHotelsDictionary = Dictionary(uniqueKeysWithValues: sortedGroupedHotels)
//        
//        self.cityNames = sortedGroupedHotelsDictionary.keys.sorted()
    }
}
