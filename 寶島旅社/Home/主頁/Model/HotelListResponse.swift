//
//  HotelListResponse.swift
//  寶島旅社
//
//  Created by wistronits on 2025/12/18.
//  Copyright © 2025 Eric Lin. All rights reserved.
//

import Foundation

struct HotelListResponse: Decodable {
    let xmlHead: XMLHead

    enum CodingKeys: String, CodingKey {
        case xmlHead = "XML_Head"
    }
}

struct XMLHead: Decodable {
    let language: String
    let listname: String
    let orgname: String
    let updatetime: String
    let infos: Infos

    enum CodingKeys: String, CodingKey {
        case language = "Language"
        case listname = "Listname"
        case orgname = "Orgname"
        case updatetime = "Updatetime"
        case infos = "Infos"
    }
}

struct Infos: Decodable {
    let info: [Hotel]

    enum CodingKeys: String, CodingKey {
        case info = "Info"
    }
}

/// 單一旅宿基本資料
struct Hotel: Codable {
    /// 旅宿唯一識別碼
    let id: String

    /// 旅宿名稱
    let name: String

    /// 旅宿簡介說明
    let description: String

    /// 縣市名稱
    let region: String?

    /// 鄉鎮市區名稱
    let town: String?

    /// 完整地址字串
    let add: String?

    /// 郵遞區號
    let zipcode: String

    /// 經度 longitude
    let px: Double

    /// 緯度 latitude
    let py: Double

    /// 旅宿類型代碼
    let hotelClass: HotelClass

    /// 聯絡電話（原始格式，未正規化）
    let tel: String

    /// 官方網站 URL（可能為空字串）
    let website: String

    /// 總房間數
    let totalNumberofRooms: Int

    /// 可容納總人數
    let totalNumberofPeople: Int

    /// 無障礙房間數
    let accessibilityRooms: Int

    /// 停車位總數
    let parkingSpace: Int

    /// 停車資訊說明
    let parkinginfo: String

    /// 最低房價
    let lowestPrice: Int

    /// 最高房價
    let ceilingPrice: Int

    /// 圖片一 URL
    let picture1: String

    /// 圖片二 URL
    let picture2: String

    /// 圖片三 URL
    let picture3: String

    /// 圖片一描述文字
    let picdescribe1: String

    /// 圖片二描述文字
    let picdescribe2: String

    /// 圖片三描述文字
    let picdescribe3: String

    /// 服務設施資訊
    let serviceinfo: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case description = "Description"
        case region = "Region"
        case town = "Town"
        case add = "Add"
        case zipcode = "Zipcode"

        case px = "Px"
        case py = "Py"

        case hotelClass = "Class"
        case tel = "Tel"
        case website = "Website"

        case totalNumberofRooms = "TotalNumberofRooms"
        case totalNumberofPeople = "TotalNumberofPeople"
        case accessibilityRooms = "AccessibilityRooms"
        case parkingSpace = "ParkingSpace"
        case parkinginfo = "Parkinginfo"

        case lowestPrice = "LowestPrice"
        case ceilingPrice = "CeilingPrice"

        case picture1 = "Picture1"
        case picture2 = "Picture2"
        case picture3 = "Picture3"

        case picdescribe1 = "Picdescribe1"
        case picdescribe2 = "Picdescribe2"
        case picdescribe3 = "Picdescribe3"

        case serviceinfo = "Serviceinfo"
    }
    
    
    /// 將圖片與描述組合成 Array
    var images: [HotelImage] {
        var list = [HotelImage]()
        if !picture1.isEmpty { list.append(HotelImage(description: picdescribe1, url: picture1)) }
        if !picture2.isEmpty { list.append(HotelImage(description: picdescribe2, url: picture2)) }
        if !picture3.isEmpty { list.append(HotelImage(description: picdescribe3, url: picture3)) }
        return list
    }
    
    /// 將地址相關資訊封裝
    var addressInfo: Address {
        return Address(city: region ?? "",
                       town: town ?? "",
                       streetAddress: add ?? "",
                       zipCode: zipcode)
    }
    
    /// 價格顯示邏輯：若高低價相同則顯示單一價，不同則顯示區間
    var priceDisplayText: String {
        return lowestPrice != ceilingPrice ? "\(lowestPrice) ~ \(ceilingPrice)" : "\(ceilingPrice)"
    }

    /// 完整的地址字串 
    var fullAddress: String {
        return "\(addressInfo.city)\(addressInfo.town)\(addressInfo.streetAddress)"
    }
    
    /// 檢查此旅宿是否符合關鍵字（包含名稱、縣市、鄉鎮、地址）
    func matches(keyword: String) -> Bool {
        if keyword.isEmpty { return true }
        
        let fields = [name,
                      addressInfo.city,
                      addressInfo.town,
                      addressInfo.streetAddress]
        
        // 只要其中一個欄位包含關鍵字，就回傳 true
        return fields.contains { $0.localizedStandardContains(keyword) }
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
enum HotelClass: String, Codable  {
    /// 國際觀光旅館
    case international = "1"
    /// 一般觀光旅館
    case generalTourist = "2"
    /// 一般旅館
    case generalHotel = "3"
    /// 民宿
    case homestay = "4"
    /// 未提供
    case unknown = ""

    /// 類型中文說明
    var description: String {
        switch self {
        case .international: 
            return "國際觀光旅館"
        case .generalTourist: 
            return "一般觀光旅館"
        case .generalHotel: 
            return "一般旅館"
        case .homestay: 
            return "民宿"
        case .unknown:
            return "未提供資訊"
        }
    }
    
    /// 星級顯示格式
    var starDescription: String {
        switch self {
        case .international:  
            return "一星 ☆"
        case .generalTourist:
            return "二星 ☆☆"
        case .generalHotel:
            return "三星 ☆☆☆"
        case .homestay:
            return "四星 ☆☆☆☆"
        case .unknown:
            return ""
        }
    }
}
