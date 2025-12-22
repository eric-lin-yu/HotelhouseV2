//
//  MapSearchViewModel.swift
//  寶島旅社
//
//  Created by wistronits on 2025/12/22.
//  Copyright © 2025 Eric Lin. All rights reserved.
//

import Foundation
import MapKit

class MapSearchViewModel {
    
    private var allHotels: [Hotel] {
        return HotelDataManager.shared.allHotels
    }
    
    private let regionRadius: Double = 1000.0 // 1公里半徑
    
    // 給 VC 使用的過濾後資料
    private(set) var filteredHotels: [Hotel] = []
    
    init() {
        
    }
    
    // MARK: - Logic
    
    /// 根據地圖中心點，過濾出半徑內的旅店並生成標記
    func getAnnotations(for centerCoordinate: CLLocationCoordinate2D) -> [MKPointAnnotation] {
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        
        // 過濾資料
        self.filteredHotels = self.allHotels.filter { hotel in
            let hotelLocation = CLLocation(latitude: hotel.py, longitude: hotel.px)
            return centerLocation.distance(from: hotelLocation) <= self.regionRadius
        }
        
        // 轉換為地圖標記
        return self.filteredHotels.map { hotel in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: hotel.py, longitude: hotel.px)
            annotation.title = hotel.name
            annotation.subtitle = hotel.hotelClass.description
            return annotation
        }
    }
    
    /// 根據標記標題反查 Hotel 物件
    func getHotel(from title: String?) -> Hotel? {
        return self.filteredHotels.first {
            $0.name == title
        }
    }
}
