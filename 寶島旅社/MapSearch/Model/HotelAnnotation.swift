//
//  HotelAnnotation.swift
//  寶島旅社
//
//  Created by Eric Lin on 2026/1/2.
//  Copyright © 2026 Eric Lin. All rights reserved.
//

import MapKit

class HotelAnnotation: MKPointAnnotation {
    var isFavorited: Bool = false
    var hotelID: String = ""
    var imageUrl: String = ""
}
