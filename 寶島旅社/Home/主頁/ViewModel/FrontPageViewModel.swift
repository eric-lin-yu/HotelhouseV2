//
//  FrontPageViewModel.swift
//  寶島旅社
//
//  Created by wistronits on 2025/12/18.
//  Copyright © 2025 Eric Lin. All rights reserved.
//

import Foundation

class FrontPageViewModel {
    
    func fetchHotels(completion: @escaping (Result<[Hotels], Error>) -> Void) {
        APIManager.shared.sendGet(endpoint: APIInfo.hotelList,
                                  responseType: HotelDataModel.self) { result in
            switch result {
            case .success(let data):
                completion(.success(data.hotels))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
