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
    @IBOutlet weak var mapSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var userLocationImageView: UIImageView!
    @IBOutlet weak var userLocationBaseView: UIView! {
        didSet {
            self.userLocationBaseView.addRoundBorder(borderColor: .sageGreen,
                                                     backgroundColor: .sageGreen)
        }
    }
    
    private var circleOverlay: MKCircle?
    
    private var viewModel: MapSearchViewModel
    
    private var searchTimer: Timer?

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
            self.mapSegmentedControl.removeRoundBorder()
            self.mapView.mapType = .standard
        case 1:
            // 混合
            self.mapSegmentedControl.setTitle("混合", forSegmentAt: 1)
            self.mapSegmentedControl.addRoundBorder(borderColor: .sageGreen,
                                                    backgroundColor: .sageGreen)
            self.mapView.mapType = .hybrid
        default:
            break
        }
    }
}

// MARK: - MapDelegate
extension MapSearchViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // 停止之前的計時器
        self.searchTimer?.invalidate()
        
        // 延遲 0.1 秒才執行，避免滑動過程中的連續觸發
        self.searchTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.updateMapOverlayAndAnnotations(center: mapView.centerCoordinate)
        }
    }

    // annotation Cellout view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        let identifier = "HotelAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
            iconView.contentMode = .scaleAspectFill
            iconView.layer.cornerRadius = 6
            iconView.clipsToBounds = true
            iconView.backgroundColor = .systemGray6
            
            annotationView?.leftCalloutAccessoryView = iconView
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
            if let iconView = annotationView?.leftCalloutAccessoryView as? UIImageView {
                // 重置為 nil 等待 didSelect 觸發加載
                iconView.image = nil
                iconView.backgroundColor = .systemGray6
            }
        }
        
        // 根據收藏狀態切換 UI
        if let hotelAnno = annotation as? HotelAnnotation {
            if hotelAnno.isFavorited {
                // 已收藏
                annotationView?.markerTintColor = .orangeRed
                annotationView?.glyphImage = UIImage(systemName: "heart.fill")
                annotationView?.displayPriority = .required
            } else {
                // 未收藏
                annotationView?.markerTintColor = .sageGreen
                annotationView?.glyphImage = UIImage(systemName: "mappin.and.ellipse")
                annotationView?.displayPriority = .defaultLow
            }
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let hotelAnno = view.annotation as? HotelAnnotation,
              let iconView = view.leftCalloutAccessoryView as? UIImageView else { return }
        
        // 有圖則不處理
        if iconView.image != nil && iconView.image != UIImage(named: "iconError") { return }
        
        // 開啟一個非同步任務
        Task {
            // 執行載入並獲取結果
            let loadedImage = await iconView.loadImage(from: hotelAnno.imageUrl)
            
            // 驗證標記是否仍為同一個
            if view.annotation === hotelAnno {
                iconView.image = loadedImage ?? UIImage(named: "iconError")
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let iconView = view.leftCalloutAccessoryView as? UIImageView {
            // 使用者收起氣泡後，清空圖片以節省內存
            iconView.image = nil
            iconView.backgroundColor = .systemGray6
        }
    }
    
    // touch Callout 面板
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let title = view.annotation?.title ?? "",
              let hotel = self.viewModel.getHotel(from: title) else { return }
        
        // 跳轉 Detail
        let viewModel = HotelDetailsViewModel(hotel: hotel)
        let vc = HotelDetailsViewController(viewModel: viewModel)
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

