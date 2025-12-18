//
//  FrontPageViewModel.swift
//  寶島旅社
//
//  Created by wistronits on 2025/12/18.
//  Copyright © 2025 Eric Lin. All rights reserved.
//

import Foundation

protocol FrontPageViewModelDelegate: AnyObject {
    func reloadData()
    func viewModelDidFail(_ error: Error)
}

class FrontPageViewModel {
    
    weak var delegate: FrontPageViewModelDelegate?
    
    private(set) var allHotels: [Hotel] = []
    private(set) var filteredHotels: [Hotel] = []
    
    var numberOfRows: Int {
        filteredHotels.count
    }
    
    func hotel(at index: Int) -> Hotel {
        filteredHotels[index]
    }
    
    func fetchHotels() {
        LoadingPageView.shard.show()
        APIManager.shared.sendGet(endpoint: APIInfo.hotelList,
                                  responseType: HotelListResponse.self) { [weak self] result in
            guard let self else { return }
            LoadingPageView.shard.dismiss()
            switch result {
            case .success(let response):
                self.allHotels = response.hotels
                self.filteredHotels = response.hotels
                self.delegate?.reloadData()
                
            case .failure(let error):
                self.delegate?.viewModelDidFail(error)
            }
        }
    }
    
    func search(keyword: String) {
        let normalized = keyword.replacingOccurrences(of: "台", with: "臺")

        filteredHotels = allHotels.filter {
            $0.matches(keyword: normalized)
        }

        delegate?.reloadData()
    }

    private func filter(keyword: String) {
        guard !keyword.isEmpty else {
            filteredHotels = allHotels
            delegate?.reloadData()
            return
        }
        
        let text = keyword.replacingOccurrences(of: "台", with: "臺")
        
        filteredHotels = allHotels.filter {
            $0.address.city.contains(text) ||
            $0.address.town.contains(text) ||
            $0.address.streetAddress.contains(text) ||
            $0.hotelName.contains(text)
        }
        
        delegate?.reloadData()
    }
}
