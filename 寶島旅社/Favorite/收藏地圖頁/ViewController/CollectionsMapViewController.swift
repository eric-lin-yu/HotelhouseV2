//
//  CollectionsMapViewController.swift
//  寶島旅社
//
//  Created by Eric Lin on 2025/12/31.
//  Copyright © 2025 Eric Lin. All rights reserved.
//

import UIKit
import MapKit

class CollectionsMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var collectionView: UICollectionView!
    
    /// 存儲目前取得的使用者座標
    private var currentUserLocation: CLLocation?
    
    private var viewModel: CollectionsMapViewModel

    init(viewModel: CollectionsMapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: CollectionsMapViewController.className, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMapUI()
        self.initialLocation()
        self.setupCollectionView()
        
        
        // 啟動定位流程
        LocationManager.shared.getUserLocation { [weak self] location in
            guard let self = self else { return }
            self.currentUserLocation = location
            // 取得定位後，刷新 CollectionView
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.presentingViewController?.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.presentingViewController?.tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - Action

extension CollectionsMapViewController {
    
    /// 點擊關閉按鈕
    @IBAction func closeTapped() {
        self.dismiss(animated: true)
    }
    
    /// 點擊地圖空白處
    @objc private func handleMapTap() {
        UIView.animate(withDuration: 0.3) {
            self.collectionView.alpha = self.collectionView.isHidden ? 1 : 0
        } completion: { _ in
            self.collectionView.isHidden.toggle()
        }
    }
}

// MARK: - Private

extension CollectionsMapViewController {
    
    /// 初始化 mapView UI
    private func setupMapUI() {
        // 初始化標記
        self.mapView.addAnnotations(self.viewModel.annotations)
        
        self.mapView.showsUserLocation = true
        // 點擊地圖空白處隱藏卡片
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        self.mapView.addGestureRecognizer(tap)
    }
    
    /// 初始進入頁面時，將視圖對準第一間旅社
    private func initialLocation() {
        guard let firstHotel = self.viewModel.hotel(at: 0) else { return }
        
        // 移動地圖中心點
        self.focusOnHotel(hotel: firstHotel)
        
        // 選中第一個標記
        if let firstAnnotation = self.viewModel.annotations.first {
            self.mapView.selectAnnotation(firstAnnotation, animated: true)
        }
        
        // 確保 CollectionView 初始在第一筆
        let firstIndexPath = IndexPath(item: 0, section: 0)
        self.collectionView.scrollToItem(at: firstIndexPath, at: .centeredHorizontally, animated: false)
    }

    /// 初始化 CollectionView
    private func setupCollectionView() {
        // 註冊 Cell
        let nib = UINib(nibName: HotelMapCollectionViewCell.className, bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: HotelMapCollectionViewCell.className)
        
        // 設定 Layout
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            // 設定寬度稍微小於螢幕，可以看到左右鄰近的卡片邊緣
            let itemWidth = view.bounds.width - 60
            layout.itemSize = CGSize(width: itemWidth, height: 130)
            layout.minimumLineSpacing = 20
            layout.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        }
        // 滑動時更有手感
        self.collectionView.decelerationRate = .fast
    }
    
    /// 取得旅社的標記
    private func focusOnHotel(hotel: Hotel) {
        let coordinate = CLLocationCoordinate2D(latitude: Double(hotel.py), longitude: Double(hotel.px))
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        self.mapView.setRegion(region, animated: true)
    }
}

// MARK: - MKMapViewDelegate

extension CollectionsMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? MKPointAnnotation,
              let index = viewModel.index(for: annotation) else { return }
        
        self.collectionView.isHidden = false
        self.collectionView.alpha = 1
        let indexPath = IndexPath(item: index, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - UICollectionView
extension CollectionsMapViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.hotels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HotelMapCollectionViewCell.className, for: indexPath) as! HotelMapCollectionViewCell
        
        if let hotel = self.viewModel.hotel(at: indexPath.item) {
            // 將從 LocationManager 取得的 location 傳入
            cell.configure(with: hotel, userLocation: self.currentUserLocation)
        }
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let centerX = scrollView.contentOffset.x + (scrollView.bounds.width / 2)
        if let indexPath = self.collectionView.indexPathForItem(at: CGPoint(x: centerX, y: scrollView.bounds.height / 2)),
           let hotel = self.viewModel.hotel(at: indexPath.item) {
            self.focusOnHotel(hotel: hotel)
            // 選中地圖上對應的 pin
            let annotation = self.viewModel.annotations[indexPath.item]
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
}
