//
//  HotelDetailsViewModel.swift
//  寶島旅社
//
//  Created by wistronits on 2025/12/23.
//  Copyright © 2025 Eric Lin. All rights reserved.
//
import Foundation

protocol HotelDetailsViewModelDelegate: AnyObject {
    func didUpdateImageData()
}

// MARK: - TableView ViewRowModel
struct HotelDetailsViewRowModel {
    let sectionType: HotelDetailsViewSectionType
    var cellModel: [Any]
}

// MARK: - HotelDetailsViewSectionType
enum HotelDetailsViewSectionType {
    /// 輪播圖
    case hotelImage
    /// 基本資訊 (電話、網站、地址)
    case hotelDetails
    /// 旅店描述
    case hotelDescription
    /// 設備資訊
    case hotelExtra
    /// 地圖預覽
    case hotelMap
}

class HotelDetailsViewModel {
    
    private let hotel: Hotel
    
    private(set) var contents: [HotelDetailsViewRowModel] = []
    
    var hotelName: String {
        hotel.name
    }
    
    var hotelModel: Hotel {
        hotel
    }
    
    init(hotel: Hotel) {
        self.hotel = hotel
        self.buildViewModel()
    }
}

// MARK: - TableView ViewModel Getter
extension HotelDetailsViewModel {
    func numberOfSections() -> Int {
        return contents.count
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        guard section < contents.count else { return 0 }
        return contents[section].cellModel.count
    }
    
    func rowModel(at section: Int) -> HotelDetailsViewRowModel? {
        guard section < contents.count else { return nil }
        return contents[section]
    }
}

// MARK: - Private
extension HotelDetailsViewModel {
    
    private func buildViewModel() {
        self.contents.removeAll()
        // 圖片輪播區
        self.contents.append(HotelDetailsViewRowModel(sectionType: .hotelImage,
                                                 cellModel: [hotel.images]))
        
        // 基本細節
        self.contents.append(HotelDetailsViewRowModel(sectionType: .hotelDetails,
                                                 cellModel: [hotel]))
        
        // 描述 (傳入文字或 Model)
        self.contents.append(HotelDetailsViewRowModel(sectionType: .hotelDescription,
                                                 cellModel: [hotel]))
        
        // 額外資訊
        self.contents.append(HotelDetailsViewRowModel(sectionType: .hotelExtra,
                                                 cellModel: [hotel]))
        
        // 地圖
        self.contents.append(HotelDetailsViewRowModel(sectionType: .hotelMap,
                                                 cellModel: [hotel]))
    }
}
