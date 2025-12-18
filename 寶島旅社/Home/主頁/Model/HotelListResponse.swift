//
//  HotelListResponse.swift
//  寶島旅社
//
//  Created by wistronits on 2025/12/18.
//  Copyright © 2025 Eric Lin. All rights reserved.
//

import Foundation

struct HotelListResponse: Codable {
    /// API 建議更新週期（分鐘）
    let updateInterval: String

    /// 回傳資料語系
    let language: String

    /// 資料提供單位代碼
    let providerID: String

    /// 本批資料最後更新時間（ISO 8601）
    let updateTime: String

    /// 旅宿清單
    let hotels: [Hotel]
}

/// 單一旅宿基本資料
struct Hotel: Codable {

    /// 旅宿唯一識別碼
    let hotelID: String

    /// 旅宿名稱
    let hotelName: String

    /// 旅宿簡介說明
    let description: String

    /// 緯度
    let latitude: Double

    /// 經度
    let longitude: Double

    /// 星級評等（0 代表未提供）
    let hotelStars: Int

    /// 旅宿類型代碼（可對應 HotelClass）
    let hotelClasses: [Int]

    /// 地址資訊
    let address: Address

    /// 聯絡電話清單
    let telephones: [String]

    /// 官方網站 URL
    let websiteURL: String

    /// 圖片資訊
    let images: [HotelImage]

    /// 服務資訊說明
    let serviceInfo: String

    /// 總房間數
    let totalRooms: Int

    /// 無障礙房間數
    let accessibleRooms: Int

    /// 最低房價
    let lowestPrice: Int

    /// 最高房價
    let ceilingPrice: Int

    /// 可容納總人數
    let totalCapacity: Int

    /// 停車位數量
    let parkingSpaces: Int

    /// 停車相關說明
    let parkingInfo: String

    /// 資料最後更新時間（ISO 8601）
    let updateTime: String
    
    func matches(keyword: String) -> Bool {
        hotelName.contains(keyword)
        || address.city.contains(keyword)
        || address.town.contains(keyword)
        || address.streetAddress.contains(keyword)
    }
}

/// 旅宿地址資訊
struct Address: Codable  {

    /// 縣市名稱
    let city: String

    /// 鄉鎮市區
    let town: String

    /// 街道門牌
    let streetAddress: String

    /// 郵遞區號
    let zipCode: String
}

/// 旅宿圖片資訊
struct HotelImage: Codable  {

    /// 圖片描述文字
    let description: String

    /// 圖片 URL
    let url: String
}

/// 旅宿類型定義
enum HotelClass: Int, Codable  {

    /// 國際觀光旅館
    case international = 1

    /// 一般觀光旅館
    case generalTourist = 2

    /// 一般旅館
    case generalHotel = 3

    /// 民宿
    case homestay = 4

    /// 類型中文說明
    var description: String {
        switch self {
        case .international: return "國際觀光旅館"
        case .generalTourist: return "一般觀光旅館"
        case .generalHotel: return "一般旅館"
        case .homestay: return "民宿"
        }
    }
}
