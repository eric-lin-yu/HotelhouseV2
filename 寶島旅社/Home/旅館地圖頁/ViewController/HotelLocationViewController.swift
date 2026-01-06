//
//  HotelDetailMapViewController.swift
//  寶島旅社
//
//  Created by Eric Lin on 2022/10/31.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit
import MapKit

class HotelLocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapActionSegmentedControl: UISegmentedControl!
    
    private var viewModel: HotelLocationViewModel
    
    init(viewModel: HotelLocationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: HotelLocationViewController.className, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.showHotelPinOnMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setupTransparentAppearance()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setupDefaultAppearance()
    }
    
    @IBAction func actionSegmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // 顯示旅店
            self.showHotelPinOnMap()
            
        case 1: // 路徑規劃
            LocationManager.shared.getUserLocation { [weak self] location in
                self?.mapView.showsUserLocation = true
                // 追蹤使用者位置
                self?.mapView.userTrackingMode = .follow
                self?.viewModel.updateUserLocation(location)
                self?.drawRouteLine()
            }
        case 2: // 導航選單
            self.showNavigationActionSheet()
            sender.selectedSegmentIndex = 0
        default:
            break
        }
    }
}

// MARK: - Private

extension HotelLocationViewController {
    
    private func setupUI() {
        self.mapActionSegmentedControl.removeAllSegments()
        
        self.mapActionSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.orangeRed,
                                                               .font: UIFont.systemFont(ofSize: 17)], for: .normal)
        
        self.mapActionSegmentedControl.insertSegment(withTitle: "旅店位置", at: 0, animated: false)
        self.mapActionSegmentedControl.insertSegment(withTitle: "路徑規劃", at: 1, animated: false)
        self.mapActionSegmentedControl.insertSegment(withTitle: "開啟導航", at: 2, animated: false)
        self.mapActionSegmentedControl.selectedSegmentIndex = 0
        
        
    }
    
    /// 顯示導航選擇選單
    private func showNavigationActionSheet() {
        let alert = UIAlertController(title: "選擇導航應用", message: "請選擇您偏好的地圖工具", preferredStyle: .actionSheet)
        
        // Apple Maps
        let appleAction = UIAlertAction(title: "Apple 導航", style: .default) { [weak self] _ in
            self?.viewModel.openAppleMapNavigation()
        }
        
        // Google Maps
        let googleAction = UIAlertAction(title: "Google 導航", style: .default) { [weak self] _ in
            self?.viewModel.openGoogleMapNavigation { installed in
                if !installed {
                    self?.view.showToast(text: "尚未安裝 Google Maps")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(appleAction)
        alert.addAction(googleAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    /// 僅顯示旅店位置
    private func showHotelPinOnMap() {
        self.mapView.removeOverlays(self.mapView.overlays)
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.viewModel.hotelCoordinate
        annotation.title = self.viewModel.hotel.name
        
        self.mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: self.viewModel.hotelCoordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        self.mapView.setRegion(region, animated: true)
    }
    
    /// 繪製路線
    private func drawRouteLine() {
        // 確認是否有使用者位置
        guard let _ = viewModel.userLocation else {
            self.view.showToast(text: "無法取得您的位置")
            return
        }
        
        LoadingPageView.shard.show()
        
        // 呼叫路徑計算
        self.viewModel.calculateRoute { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                LoadingPageView.shard.dismiss()
                
                switch result {
                case .success(let route):
                    self.mapView.removeOverlays(self.mapView.overlays)
                    
                    // 加入路線
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                    
                    // 自動縮放至能看見全景
                    self.mapView.setVisibleMapRect(
                        route.polyline.boundingMapRect,
                        edgePadding: UIEdgeInsets(top: 80, left: 50, bottom: 50, right: 50),
                        animated: true
                    )
                    
                case .failure(let error):
                    print("路徑規劃錯誤: \(error)")
                    self.view.showToast(text: "路徑規劃失敗")
                }
            }
        }
    }
}

// MARK: - MKMapViewDelegate
extension HotelLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .orangeRed
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
}
