//
//  AboutViewSectionType.swift
//  寶島旅社
//
//  Created by Eric Lin on 2026/1/6.
//  Copyright © 2026 Eric Lin. All rights reserved.
//

enum AboutViewSectionType: CaseIterable {
    case about
    case setup
    
    var title: String {
        switch self {
        case .about: 
            return "關於"
        case .setup: 
            return "設定"
        }
    }
}

enum AboutViewRowType {
    case appVersion
    case apiSource
    case updateDate
    case hotelCount
    case downloadData
    
    var title: String {
        switch self {
        case .appVersion: 
            return "APP版本"
        case .apiSource:  
            return "資料來源"
        case .updateDate: 
            return "資料庫版本"
        case .hotelCount:
            return "目前資料庫總筆數"
        case .downloadData:
            return "下載離線資料"
        }
    }
}
