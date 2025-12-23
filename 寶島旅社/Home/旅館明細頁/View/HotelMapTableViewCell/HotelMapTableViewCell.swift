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
    //  "Region": "南投縣", "Town": "埔里鎮"
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var townLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(dataModel: Hotel) {
        regionLabel.text = dataModel.region
        townLabel.text = dataModel.town
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(dataModel.add ?? "") { (placemarks, error) in
            if let error = error {
                print("地址轉換失敗：\(error.localizedDescription)")
                
                let annotation = MKPointAnnotation()
                annotation.title = dataModel.name
                annotation.coordinate = CLLocationCoordinate2D(latitude: dataModel.py,
                                                               longitude: dataModel.px)
                
                self.mapView.addAnnotation(annotation)
                self.mapView.showAnnotations([annotation], animated: true)
                self.mapView.selectAnnotation(annotation, animated: true)
                
                let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
                self.mapView.setRegion(region, animated: false)
                
                return
            }
            
            if let location = placemarks?.first?.location {
                let annotation = MKPointAnnotation()
                annotation.title = dataModel.name
                annotation.coordinate = location.coordinate
                
                self.mapView.addAnnotation(annotation)
                self.mapView.showAnnotations([annotation], animated: true)
                self.mapView.selectAnnotation(annotation, animated: true)
                
                let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
                self.mapView.setRegion(region, animated: false)
            }
        }
    }
    
}
