//
//  MapSearchViewController.swift
//  寶島旅社
//
//  Created by Eric Lin on 2022/11/17.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit
import MapKit

class MapSearchViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSegmentedControl: UISegmentedControl! {
        didSet {
            self.mapSegmentedControl.addRoundBorder(borderColor: .sageGreen,
                                                    backgroundColor: .sageGreen)
        }
    }
    @IBOutlet weak var userLocationImageView: UIImageView!
    @IBOutlet weak var userLocationBaseView: UIView! {
        didSet {
            self.userLocationBaseView.addRoundBorder(borderColor: .sageGreen,
                                                     backgroundColor: .sageGreen)
        }
    }
    
    private var circleOverlay: MKCircle?
    
    private var viewModel: MapSearchViewModel

    init(viewModel: MapSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: MapSearchViewController.className, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupMap()

        self.mapSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.orangeRed,
                                                    .font: UIFont.systemFont(ofSize: 17)], for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector((getUserLocation)))
        self.userLocationImageView.isUserInteractionEnabled = true
        self.userLocationImageView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

// MARK: - Private

extension MapSearchViewController {
    
    /// 設定地圖資訊
    private func setupMap() {
        self.mapView.delegate = self
        
        // 初始定位與設定顯示使用者藍點
        self.mapView.showsUserLocation = true
        self.getUserLocation()
    }
    
    /// 更新地圖上的搜尋範圍覆蓋層與旅宿標記
    /// - Parameter center: 作為搜尋依據的地圖中心座標（緯度 / 經度）
    private func updateMapOverlayAndAnnotations(center: CLLocationCoordinate2D) {
        // 處理紅圈 (搜尋範圍)
        if let existing = self.circleOverlay {
            self.mapView.removeOverlay(existing)
        }
        
        let newCircle = MKCircle(center: center, radius: 1000.0)
        self.circleOverlay = newCircle
        self.mapView.addOverlay(newCircle)
        
        // 取得旅店標記
        let annotations = self.viewModel.getAnnotations(for: center)
        
        // 使用者位置
        let hotelAnnotations = self.mapView.annotations.filter { !($0 is MKUserLocation) }
        self.mapView.removeAnnotations(hotelAnnotations)
        
        // 加入新的旅店標記
        self.mapView.addAnnotations(annotations)
    }
    
    /// 處理使用者定位成功後的地圖更新行為
    private func handleUserLocation(_ location: CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        self.mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
        self.updateMapOverlayAndAnnotations(center: location.coordinate)
        
        // 延遲顯示定位按鈕
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.userLocationImageView.isHidden = false
            self.userLocationBaseView.isHidden = false
        }
    }
}

// MARK: - Action

extension MapSearchViewController {
    
    @objc func getUserLocation() {
        LocationManager.shared.getUserLocation { [weak self] location in
            guard let self = self else { return }
            
            // 設定地圖範圍（飛到使用者位置）
            let region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            self.mapView.setRegion(region, animated: true)
            
            // 更新圓圈與標記
            self.updateMapOverlayAndAnnotations(center: location.coordinate)
            
            // 延遲顯示按鈕
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.userLocationImageView.isHidden = false
                self.userLocationBaseView.isHidden = false
            }
        }
    }
    
    @IBAction func mayTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // 標準
            self.mapSegmentedControl.setTitle("標準", forSegmentAt: 0)
            self.mapView.mapType = .standard
        case 1:
            // 衛星
            self.mapSegmentedControl.setTitle("衛星", forSegmentAt: 1)
            self.mapView.mapType = .satellite
        case 2:
            // 混合
            self.mapSegmentedControl.setTitle("混合", forSegmentAt: 2)
            self.mapView.mapType = .hybrid
        default:
            break
        }
    }
}

// MARK: - MapDelegate
extension MapSearchViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.updateMapOverlayAndAnnotations(center: mapView.centerCoordinate)
    }

    // annotation Cellout view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 檢查是否為使用者定位的標記，保持預設樣式
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "CustomAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let button = UIButton(type: .detailDisclosure)
            button.tintColor = UIColor.orange
            annotationView?.rightCalloutAccessoryView = button
            
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    // touch Callout 面板
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let title = view.annotation?.title ?? "",
              let hotel = self.viewModel.getHotel(from: title) else { return }
        
        // 跳轉 Detail
        let vc = HotelDetailsViewController(hotelDataModel: hotel)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    // 繪製圓圈
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = UIColor.red
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }
}

