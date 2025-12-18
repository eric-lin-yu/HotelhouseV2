//
//  ViewModel.swift
//  寶島旅社
//
//  Created by Eric Lin on 2022/10/13.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

//class HotelViewModel {
//    
//    func getHotelBookData( _ completion: @escaping (HotelDataModel?)->()) {
//        // 本地端抓取
//        guard let url = Bundle.main.url(forResource: "HotelList", withExtension: "json") else {
//            return
//        }
//
//        // 雲端抓取
////        let url = "https://media.taiwan.net.tw/XMLReleaseALL_public/hotel_C_f.xml"
//        
//        AlamofireHandler.request(url: url) { response in
//            switch response.result {
//            case .success(_):
//                if let json: JSON = try? JSON(data: response.data!) {
//                    completion(HotelDataModel(json: json))
//                } else {
//                    ResponseHandler.errorHandler(statusCode: response.response?.statusCode, errorString: response.description)
//                }
//            case .failure(_):
//                ResponseHandler.errorHandler(statusCode: response.response?.statusCode, errorString: "發生一點錯誤，請稍後再試。")
//            }
//        }
//    }
//}
