//
//  HotelDetailsMapViewModel.swift
//  寶島旅社
//
//  Created by wistronits on 2025/12/23.
//  Copyright © 2025 Eric Lin. All rights reserved.
//

import Foundation
import MapKit

class HotelLocationViewModel {
    
    private(set) var hotel: Hotel
    private(set) var userLocation: CLLocationCoordinate2D?
    
    // 旅店座標
    var hotelCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.hotel.py,
                                      longitude: self.hotel.px)
    }
    
    var hotelName: String {
        return self.hotel.name
    }
    
    init(hotel: Hotel) {
        self.hotel = hotel
    }
    
    // MARK: - Logic
    
    /// 更新使用者位置
    func updateUserLocation(_ location: CLLocation) {
        self.userLocation = location.coordinate
    }
    
    /// 計算從使用者到旅店的路徑
    func calculateRoute(completion: @escaping (Result<MKRoute, Error>) -> Void) {
        guard let userCoord = userLocation else {
            let error = NSError(domain: "LocationError", code: 404, userInfo: [NSLocalizedDescriptionKey: "尚未取得使用者位置"])
            completion(.failure(error))
            return
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoord))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: hotelCoordinate))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                completion(.failure(error))
            } else if let route = response?.routes.first {
                completion(.success(route))
            }
        }
    }
    
    /// 開啟 Apple Maps 導航
    func openAppleMapNavigation() {
        let placemark = MKPlacemark(coordinate: hotelCoordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.hotelName
        
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: options)
    }
    
    /// 開啟 Google Maps 導航
    func openGoogleMapNavigation(completion: @escaping (Bool) -> Void) {
        let urlString = "comgooglemaps://?daddr=\(self.hotel.py),\(self.hotel.px)&directionsmode=driving"
        
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            completion(true)
        } else {
            completion(false)
        }
    }
}
