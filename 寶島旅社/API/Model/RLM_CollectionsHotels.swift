//
//  RLM_DataModel.swift
//  寶島旅社
//
//  Created by Eric Lin on 2023/7/28.
//  Copyright © 2023 Eric Lin. All rights reserved.
//

import Foundation
import RealmSwift

class RLM_CollectionsHotels: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var descriptionText: String
    @Persisted var region: String
    @Persisted var town: String
    @Persisted var add: String
    @Persisted var zipcode: String
    @Persisted var px: Double
    @Persisted var py: Double
    @Persisted var hotelClassRawValue: String
    @Persisted var tel: String
    @Persisted var website: String
    @Persisted var totalNumberofRooms: Int
    @Persisted var totalNumberofPeople: Int
    @Persisted var accessibilityRooms: Int
    @Persisted var parkingSpace: Int
    @Persisted var parkinginfo: String
    @Persisted var lowestPrice: Int
    @Persisted var ceilingPrice: Int
    
    // 圖片部分改為 List 存儲
    @Persisted var images: List<RLM_HotelImage>
    @Persisted var serviceinfo: String

    convenience init(hotel: Hotel) {
        self.init()
        self.id = hotel.id
        self.name = hotel.name
        self.descriptionText = hotel.description
        self.region = hotel.region ?? ""
        self.town = hotel.town ?? ""
        self.add = hotel.add ?? ""
        self.zipcode = hotel.zipcode
        self.px = hotel.px
        self.py = hotel.py
        self.hotelClassRawValue = hotel.hotelClass.rawValue
        self.tel = hotel.tel
        self.website = hotel.website
        self.totalNumberofRooms = hotel.totalNumberofRooms
        self.totalNumberofPeople = hotel.totalNumberofPeople
        self.accessibilityRooms = hotel.accessibilityRooms
        self.parkingSpace = hotel.parkingSpace
        self.parkinginfo = hotel.parkinginfo
        self.lowestPrice = hotel.lowestPrice
        self.ceilingPrice = hotel.ceilingPrice
        self.serviceinfo = hotel.serviceinfo
        
        // 轉換圖片
        let rlmImages = hotel.images.map { RLM_HotelImage(image: $0) }
        self.images.append(objectsIn: rlmImages)
    }
}

class RLM_HotelImage: Object {
    @Persisted var imageDescription: String
    @Persisted var url: String
    
    convenience init(image: HotelImage) {
        self.init()
        self.imageDescription = image.description
        self.url = image.url
    }
}
