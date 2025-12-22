//
//  HotelDataManager.swift
//  寶島旅社
//
//  Created by wistronits on 2025/12/22.
//  Copyright © 2025 Eric Lin. All rights reserved.
//
import UIKit

class HotelDataManager {
    static let shared = HotelDataManager()
    
    // 記憶體快取
    var allHotels: [Hotel] = []
    
    private let fileName = "hotel_data.json"
    private init() {
        // 初始化時，先嘗試從手機硬碟讀取舊資料
        self.allHotels = loadHotelsFromDisk()
    }
    
    // MARK: - 儲存與讀取
    func saveHotelsToDisk(_ hotels: [Hotel]) {
        self.allHotels = hotels
        DispatchQueue.global(qos: .background).async {
            let url = self.getDocumentsDirectory().appendingPathComponent(self.fileName)
            do {
                let data = try JSONEncoder().encode(hotels)
                try data.write(to: url)
                print("旅店資料已成功離線存檔")
            } catch {
                print("存檔失敗: \(error)")
            }
        }
    }
    
    private func loadHotelsFromDisk() -> [Hotel] {
        let url = self.getDocumentsDirectory().appendingPathComponent(self.fileName)
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([Hotel].self, from: data)) ?? []
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
