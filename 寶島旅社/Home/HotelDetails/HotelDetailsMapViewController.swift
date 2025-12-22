//
//  HotelDetailMapViewController.swift
//  寶島旅社
//
//  Created by Eric Lin on 2022/10/31.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit
import MapKit

enum MapType {
    case hotelHere
    case userHere
}

enum MapButtonViewStatus {
    case showImage
    case showButtonView
}

class HotelDetailsMapViewController: UIViewController {
    static func make(hotelData: Hotel) -> HotelDetailsMapViewController {
        let storyboard = UIStoryboard(name: "HotelDetailsStoryboard", bundle: nil)
        let vc: HotelDetailsMapViewController = storyboard.instantiateViewController(withIdentifier: "HotelDetailMapIdentifier") as! HotelDetailsMapViewController
        
        vc.dataModel = hotelData
        
        return vc
    }
    
    @IBOutlet weak var mapSegmentedControl: UISegmentedControl! {
        didSet {
            //圓角
            mapSegmentedControl.layer.cornerRadius = 15
            mapSegmentedControl.layer.masksToBounds = true
            
            //邊框線條
            mapSegmentedControl.layer.borderWidth = 2
            mapSegmentedControl.layer.borderColor = UIColor.sageGreen.cgColor
            
            mapSegmentedControl.backgroundColor = .sageGreen
        }
    }
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var buttonView: UIView! {
        didSet {
            buttonView.addRoundBorder()
        }
    }
    @IBOutlet weak var userLocationBtn: UIButton!
    @IBOutlet weak var hotelLocationBtn: UIButton!
    @IBOutlet weak var distanceBtn: UIButton!
    @IBOutlet weak var navigationMAPBtn: UIButton!
    @IBOutlet weak var isButtonImageView: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    
    var dataModel: Hotel! = nil
    
    var mapType: MapType!
    var mapButtonType: MapButtonViewStatus!
    
    let manager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 更改UISegmentedControl字體
        mapSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.orangeRed,
                                              .font: UIFont.systemFont(ofSize: 17)], for: .normal)
        // 預設先show出旅店位置
        getHotelLocation()
        self.mapView.delegate = self
        
        userLocationBtn.addTarget(self, action: #selector(getUserLocation), for: .touchUpInside)
        hotelLocationBtn.addTarget(self, action: #selector(getHotelLocation), for: .touchUpInside)
        distanceBtn.addTarget(self, action: #selector(getUserHotelDistance), for: .touchUpInside)
        navigationMAPBtn.addTarget(self, action: #selector(getNavigationMAPBtn), for: .touchUpInside)
        
        mapButtonType = .showImage
        buttonView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(isCheckShowButtonView))
        isButtonImageView.addGestureRecognizer(tap)
        isButtonImageView.isUserInteractionEnabled = true
        
        let viewtap = UITapGestureRecognizer(target: self, action: #selector(isCheckShowButtonView))
        self.view.addGestureRecognizer(viewtap)
        
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 關閉navigation
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 開啟navigation
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func isCheckShowButtonView() {
        switch mapButtonType {
        case .showButtonView:
            buttonView.isHidden = true
            isButtonImageView.isHidden = false
            mapButtonType = .showImage
        case .showImage:
            buttonView.isHidden = false
            isButtonImageView.isHidden = true
            mapButtonType = .showButtonView
        default:
            break
        }
    }
    
    @IBAction func mayTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // 標準
            mapSegmentedControl.setTitle("標準", forSegmentAt: 0)
            mapView.mapType = .standard
        case 1:
            // 衛星
            mapSegmentedControl.setTitle("衛星", forSegmentAt: 1)
            mapView.mapType = .satellite
        case 2:
            // 混合
            mapSegmentedControl.setTitle("混合", forSegmentAt: 2)
            mapView.mapType = .hybrid
        default:
            break
        }
    }
    // MARK: Button Func
    /// 取得使用者位置標記
    @objc func getUserLocation() {
        manager.activityType = .automotiveNavigation
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        
        switch manager.authorizationStatus {
        case .notDetermined:
            // 首次使用 向user取得隱私權限
            manager.requestWhenInUseAuthorization()
            
        case .denied, .restricted:
            // user已拒絕過權限 或 未開啟定位功能
            let message = "如欲使用此功能，請開啟定位權限\n\n請至\n設定 > 隱私權與安全性 >\n定位服務 > 永許旅社取得您得位置。"
            showAlertClosure(title: "定位權限已關閉", message: message, okBtn: "前往開啟") {
                // 開啟設定
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }
        case .authorizedWhenInUse:
            // user接受
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
    /// 取得旅店位置標記
    @objc func getHotelLocation() {
        let geoCoder = CLGeocoder()  //取得位置
        
        geoCoder.geocodeAddressString(self.dataModel.fullAddress) { (placemarks, error) in
            if let error = error {
                print("地址轉換失敗：\(error.localizedDescription)")
            }
            
            let annotation = MKPointAnnotation()  //加入標記
            annotation.title = self.dataModel.name
            annotation.subtitle = self.dataModel.town
            
            if placemarks != nil {
                let placemark = placemarks?[0] //取得地點標記
                if let location = placemark?.location {
                    annotation.coordinate = location.coordinate
                }
            } else {
                //改抓經、緯度
                let py = self.dataModel.py
                let px = self.dataModel.px
                
                annotation.coordinate = CLLocationCoordinate2D(latitude: py,
                                                               longitude: px)
            }
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    /// 取得兩者距離並劃線
    @objc func getUserHotelDistance() {
        guard let userLocation = userLocation else {
            showAlertClosure(title: "通知", message: "APP尚未取得您的位置資訊\n是否同意先取得您的位置資訊?", okBtn: "確認") {
                // 先取得user的位置
                self.getUserLocation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    // 再次呼叫此func
                    self.getUserHotelDistance()
                }
            }
            return
        }

        LoadingPageView.shard.show()
        
        let userPlacemark = MKPlacemark(coordinate: userLocation, addressDictionary: nil)
        let coordinate = CLLocationCoordinate2D(latitude: self.dataModel.py,
                                                longitude: self.dataModel.px)
        let hotelPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        
        let userMapItem = MKMapItem(placemark: userPlacemark)
        let hotelMapItem = MKMapItem(placemark: hotelPlacemark)

        let request = MKDirections.Request()
        request.source = userMapItem
        request.destination = hotelMapItem
        request.transportType = .automobile

        let directions = MKDirections(request: request)

        directions.calculate { response, error in
            LoadingPageView.shard.dismiss()
            if let error = error {
                print(error)
                self.view.showToast(text: "無法取得路線")
                return
            }

            guard let response = response, let route = response.routes.first else {
                return
            }

            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    /// 導航
    @objc func getNavigationMAPBtn() {
        let alerts = UIAlertController(title: "", message: "請選擇欲使用的導航APP", preferredStyle: .actionSheet)
        
        // apple導航
        let appleBtn = UIAlertAction(title: "Apple 導航", style: .default) { _ in
            self.goToAppleMap()
        }
        alerts.addAction(appleBtn)
        
        // google導航
        let googleBtn = UIAlertAction(title: "Google 導航", style: .default) { _ in
            self.goToGoogleMap()
        }
        alerts.addAction(googleBtn)
        
        let cancelBtn = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        alerts.addAction(cancelBtn)
        self.present(alerts, animated: true, completion: nil)
    }
    
    // 開啟appleMap導航
    func goToAppleMap() {
        let geocoder = CLGeocoder()
        let adderss = dataModel.add ?? ""
        geocoder.geocodeAddressString(adderss) { (placemarks, error) in
            if let error = error {
                print("地址轉換失敗：\(error.localizedDescription)")
            }
            var targetCoordinate = CLLocationCoordinate2D()
            
            if placemarks != nil {
                let placemark = placemarks?[0] // 取得地點標記
                if let location = placemark?.location {
                    targetCoordinate = location.coordinate
                }
            } else {
                // 改抓經、緯度
                let py = self.dataModel.py
                let px = self.dataModel.px
                
                targetCoordinate = CLLocationCoordinate2D(latitude: py,
                                                          longitude: px)
            }
            
            let theFirstPlaceMark = MKPlacemark(coordinate: targetCoordinate)
            let taragetPlace = MKPlacemark(placemark: theFirstPlaceMark)
            let targetMapItem = MKMapItem(placemark: taragetPlace)
            
            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            targetMapItem.openInMaps(launchOptions: options)
        }
    }
    
    // 開啟GoogleMap導航
    func goToGoogleMap() {
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            let py = self.dataModel.py
            let px = self.dataModel.px
            let urlString = "comgooglemaps://?&saddr=&daddr=\(py),\(px)&directionsmode=driving"
            
            guard let url = URL(string: urlString) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            showAlertClosure(title: "通知", message: "您尚未安裝GoogleMap", okBtn: "前往下載") {
                guard let url = URL(string: "https://apps.apple.com/tw/app/id585027354") else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
}

// MARK: - LocationManagerDelegate
extension HotelDetailsMapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latLocation = locations.last else{
            assertionFailure("Invalid lcoation or coordinate.")
            return
        }
        let coordinate = latLocation.coordinate
        userLocation = coordinate
        
        // 定位到map時,放大畫面到定位的位置
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // 放大的畫面經緯度範圍
        let region = MKCoordinateRegion(center:coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        // 新增一個地標,在user's旁
        var storeCoordinate = coordinate
        storeCoordinate.latitude += 0.0001
        storeCoordinate.longitude += 0.0001
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = storeCoordinate
        annotation.title = "Here!"
        
        mapView.addAnnotation(annotation) // 新增到mapView上
        
        manager.stopUpdatingLocation()
    }
    
    // 畫出路線圖
    func mapView (_ mapView: MKMapView, rendererFor overlay: MKOverlay ) -> MKOverlayRenderer {
        let renderer =  MKPolylineRenderer (overlay: overlay)
        renderer.strokeColor =  UIColor.orange
        renderer.lineWidth =  4.0

        return renderer
    }
    
    
}
