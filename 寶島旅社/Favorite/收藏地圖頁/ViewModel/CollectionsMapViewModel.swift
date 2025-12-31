//
//  CollectionsMapViewModel.swift
//  寶島旅社
//
//  Created by Eric Lin on 2025/12/31.
//  Copyright © 2025 Eric Lin. All rights reserved.
//

import Foundation
import MapKit

class CollectionsMapViewModel {
    /// 持有的旅店資料
    private(set) var hotels: [Hotel]
    
    /// 提供給 MapView 使用的 Annotation 清單
    private(set) var annotations: [MKPointAnnotation] = []
    
    init(hotels: [Hotel]) {
        self.hotels = hotels
        self.createAnnotations()
    }
    
    /// 建立地圖標記點
    private func createAnnotations() {
        self.annotations = hotels.map { hotel in
            let annotation = MKPointAnnotation()
            annotation.title = hotel.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(hotel.py),
                                                           longitude: Double(hotel.px))
            return annotation
        }
    }
    
    /// 取得指定 index 的旅店資料
    func hotel(at index: Int) -> Hotel? {
        guard index < self.hotels.count else { return nil }
        return self.hotels[index]
    }
    
    /// 根據 Annotation 找尋對應的 Index（連動 CollectionView）
    func index(for annotation: MKPointAnnotation) -> Int? {
        return self.annotations.firstIndex(of: annotation)
    }
}
