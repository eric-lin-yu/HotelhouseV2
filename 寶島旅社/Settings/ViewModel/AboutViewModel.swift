//
//  AboutViewModel.swift
//  寶島旅社
//
//  Created by Eric Lin on 2026/1/6.
//  Copyright © 2026 Eric Lin. All rights reserved.
//

import Foundation

// MARK: - TableView RowModel
struct AboutViewRowModel {
    let type: AboutViewRowType
    let subtitle: String
    let isClickable: Bool
}

class AboutViewModel {
    
    private(set) var contents: [(section: AboutViewSectionType, rows: [AboutViewRowModel])] = []
    /// App 版本
    private let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    
    init() {
        self.buildViewModel()
    }
    
    func buildViewModel() {
        self.contents.removeAll()
        
        // 1. 關於區塊
        let updateDate = HotelDataManager.shared.lastUpdateDate.formatDateToYearMonthDay() ?? HotelDataManager.shared.lastUpdateDate
        
        let aboutRows = [
            AboutViewRowModel(type: .appVersion, subtitle: self.appVersion, isClickable: false),
            AboutViewRowModel(type: .apiSource, subtitle: "政府資料開放平臺", isClickable: true),
            AboutViewRowModel(type: .updateDate, subtitle: updateDate, isClickable: false),
            AboutViewRowModel(type: .hotelCount, subtitle: "\(HotelDataManager.shared.totalCount) 間", isClickable: false)
        ]
        self.contents.append((.about, aboutRows))
        
        // 2. 設定區塊
        let setupRows = [
            AboutViewRowModel(type: .underDesign, subtitle: "我還在想要做什麼", isClickable: false)
        ]
        self.contents.append((.setup, setupRows))
    }
}

// MARK: - TableView ViewModel Getter
extension AboutViewModel {
    func numberOfSections() -> Int {
        return self.contents.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        return self.contents[section].rows.count
    }
    
    func rowModel(at indexPath: IndexPath) -> AboutViewRowModel {
        return self.contents[indexPath.section].rows[indexPath.row]
    }
}
