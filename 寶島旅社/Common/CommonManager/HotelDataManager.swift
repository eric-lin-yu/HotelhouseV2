//
//  HotelDataManager.swift
//  寶島旅社
//
//  Created by wistronits on 2025/12/22.
//  Copyright © 2025 Eric Lin. All rights reserved.
//
import UIKit

/// 版本比對結果
enum VersionCheckResult {
    /// 已是最新
    case upToDate
    /// 需要更新，並帶回伺服器時間
    case needUpdate(serverTime: String)
    /// 網路請求失敗
    case failure(Error)
}

class HotelDataManager {
    
    struct HotelCache: Codable {
        let lastUpdateDate: String
        let hotels: [Hotel]
    }
    
    static let shared = HotelDataManager()
    
    var allHotels: [Hotel] = []
    /// 最後更新時間
    var lastUpdateDate: String = ""
    
    var totalCount: Int {
        return allHotels.count
    }
    
    private let fileName = "hotel_data.json"
    private init() {
        // 初始化時，手機硬碟讀取舊資料
        loadDataFromDisk()
    }
    
    /// 儲存傳入旅店列表與來源 API 的 updatetime
    func saveHotelsToDisk(_ hotels: [Hotel], updateTime: String) {
        self.allHotels = hotels
        self.lastUpdateDate = updateTime
        
        let cache = HotelCache(lastUpdateDate: updateTime, hotels: hotels)
        
        DispatchQueue.global(qos: .background).async {
            let url = self.getDocumentsDirectory().appendingPathComponent(self.fileName)
            do {
                let data = try JSONEncoder().encode(cache)
                try data.write(to: url)
                print("旅店資料與更新日期已成功存檔")
            } catch {
                print("存檔失敗: \(error)")
            }
        }
    }
    
    /// 離線資料庫版本檢查
    func checkVersion(completion: @escaping (VersionCheckResult) -> Void) {
        APIManager.shared.sendGet(endpoint: APIInfo.hotelList, responseType: HotelListResponse.self) { result in
            switch result {
            case .success(let response):
                let serverTime = response.xmlHead.updatetime
                let localTime = self.lastUpdateDate
                
                // API 成功回傳，標記今日已檢查
                self.markAsUpdatedNow()
                
                if serverTime == localTime {
                    completion(.upToDate)
                } else {
                    completion(.needUpdate(serverTime: serverTime))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// 讀取
    private func loadDataFromDisk() {
        let url = self.getDocumentsDirectory().appendingPathComponent(self.fileName)
        guard let data = try? Data(contentsOf: url),
              let cache = try? JSONDecoder().decode(HotelCache.self, from: data) else {
            self.lastUpdateDate = "尚未下載"
            return
        }
        
        self.allHotels = cache.hotels
        self.lastUpdateDate = cache.lastUpdateDate
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

extension HotelDataManager {
    
    private var lastCheckKey: String { "last_data_check_timestamp" }
    
    /// 檢查今天是否已經更新過
    var isUpdatedToday: Bool {
        let lastCheck = UserDefaults.standard.double(forKey: lastCheckKey)
        let lastCheckDate = Date(timeIntervalSince1970: lastCheck)
        
        // 判斷是否為「今天」或是「24小時內」
        return Calendar.current.isDateInToday(lastCheckDate)
    }
    
    /// 紀錄現在已經執行過更新檢查
    func markAsUpdatedNow() {
        let now = Date().timeIntervalSince1970
        UserDefaults.standard.set(now, forKey: lastCheckKey)
    }
    
    /// 重置檢查狀態，用於手動更新時
    func resetUpdateCheck() {
        UserDefaults.standard.removeObject(forKey: lastCheckKey)
    }
}
