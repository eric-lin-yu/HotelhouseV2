//
//  MapTableViewCell.swift
//  寶島旅社
//
//  Created by wistronits on 2022/10/21.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit
import MapKit

class HotelMapTableViewCell: UITableViewCell {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var roundFramView: UIView! {
        didSet {
            roundFramView.addRoundBorder()
        }
    }
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var townLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        self.mapView.isUserInteractionEnabled = false
    }
    
    func configure(dataModel: Hotel) {
        self.regionLabel.text = dataModel.region
        self.townLabel.text = dataModel.town
        
        // 清除舊的標記，避免 Cell 重用時殘留
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        // 優先判斷座標是否有效
        if dataModel.px != 0, dataModel.py != 0 {
            let coordinate = CLLocationCoordinate2D(latitude: dataModel.py, longitude: dataModel.px)
            self.setupMap(with: coordinate, title: dataModel.name)
        } else {
            // 座標無效時才進行地址編碼
            geocodeAddress(dataModel.add ?? "", title: dataModel.name)
        }
    }
    
    private func setupMap(with coordinate: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = coordinate
        
        self.mapView.addAnnotation(annotation)
        
        // 設定顯示區域 (300公尺範圍)
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 300,
                                        longitudinalMeters: 300)
        self.mapView.setRegion(region, animated: false)
    }
    
    private func geocodeAddress(_ address: String, title: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { [weak self] (placemarks, error) in
            guard let self = self,
                  let location = placemarks?.first?.location,
                  error == nil else { return }
            
            DispatchQueue.main.async {
                self.setupMap(with: location.coordinate, title: title)
            }
        }
    }
}
