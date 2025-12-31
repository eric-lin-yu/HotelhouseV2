//
//  CollectionsViewController.swift
//  寶島旅社
//
//  Created by wistronits on 2023/7/28.
//  Copyright © 2023 Eric Lin. All rights reserved.
//

import UIKit
import MapKit

class CollectionsViewController: UIViewController {
    private let viewModel: CollectionsViewModel
    
    private let manager = CLLocationManager()
    
    // constraint Spacing
    private let spacing: CGFloat = 20
    private let innerLayerSpacing: CGFloat = 10
    private let searchiconBtnSize: CGFloat = 24
    private let segmentedControlSize: CGFloat = 40
    
    //MARK: - Code UI
    private let searchView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let searchTextFiled: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.backgroundColor = .sageGreen
        textField.font = .systemFont(ofSize: 17)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17)
        ]
        let attributedPlaceholder = NSAttributedString(string: "Search", attributes: attributes)
        textField.attributedPlaceholder = attributedPlaceholder
        
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let searchiconBtn: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "iconSearch")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(withTitle: "列表", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "地圖", at: 1, animated: false)
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .sageGreen
        
        // 置中
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17),
            .paragraphStyle: paragraphStyle
        ]
        
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.orangeRed,
            .font: UIFont.systemFont(ofSize: 17),
            .paragraphStyle: paragraphStyle
        ]
        
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.isHidden = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Initialization
    init(viewModel: CollectionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupConstraint()
        self.setupTableView()
        self.setupMapView()
        self.setupBindings()
        
        self.segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.viewModel.loadHotels()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

//MARK: - setup
extension CollectionsViewController {
    
    /// 設定 Views
    private func setupViews() {
        view.backgroundColor = .white
        let viewsToAdd: [UIView] = [
            self.searchView,
            self.segmentedControl,
            self.tableView,
            self.mapView,
        ]
        viewsToAdd.forEach { view.addSubview($0) }
        
        let viewsToAddSearchView: [UIView] = [
            self.searchTextFiled,
            self.searchiconBtn,
        ]
        viewsToAddSearchView.forEach {  self.searchView.addSubview($0) }
    }
    
    /// 設定 Constraint
    private func setupConstraint() {
        let topSafeArea = view.safeAreaLayoutGuide.topAnchor
        let leftSafeArea = view.safeAreaLayoutGuide.leftAnchor
        let rightSafeArea = view.safeAreaLayoutGuide.rightAnchor
        let bottomSafeArea = view.safeAreaLayoutGuide.bottomAnchor
        
        NSLayoutConstraint.activate([
            self.searchView.topAnchor.constraint(equalTo: topSafeArea, constant:  self.spacing),
            self.searchView.leftAnchor.constraint(equalTo: leftSafeArea, constant:  self.spacing),
            self.searchView.rightAnchor.constraint(equalTo: rightSafeArea, constant: -self.spacing),
            
            self.searchTextFiled.topAnchor.constraint(equalTo:  self.searchView.topAnchor),
            self.searchTextFiled.leftAnchor.constraint(equalTo:  self.searchView.leftAnchor),
            self.searchTextFiled.rightAnchor.constraint(equalTo:  self.searchView.rightAnchor),
            self.searchTextFiled.bottomAnchor.constraint(equalTo:  self.searchView.bottomAnchor),
            
            self.searchiconBtn.topAnchor.constraint(equalTo:  self.searchView.topAnchor, 
                                                    constant:  self.innerLayerSpacing),
            self.searchiconBtn.rightAnchor.constraint(equalTo:  self.searchView.rightAnchor,
                                                      constant: -self.innerLayerSpacing),
            self.searchiconBtn.bottomAnchor.constraint(equalTo:  self.searchView.bottomAnchor,
                                                       constant: -self.innerLayerSpacing),
            self.searchiconBtn.centerYAnchor.constraint(equalTo:  self.searchView.centerYAnchor),
            self.searchiconBtn.heightAnchor.constraint(equalToConstant:  self.searchiconBtnSize),
            self.searchiconBtn.widthAnchor.constraint(equalToConstant:  self.searchiconBtnSize),
            
            self.segmentedControl.topAnchor.constraint(equalTo:  self.searchView.bottomAnchor, 
                                                       constant:  self.innerLayerSpacing),
            self.segmentedControl.leftAnchor.constraint(equalTo:  self.searchView.leftAnchor),
            self.segmentedControl.rightAnchor.constraint(equalTo:  self.searchView.rightAnchor),
            self.segmentedControl.heightAnchor.constraint(equalToConstant:  self.segmentedControlSize),
            
            self.tableView.topAnchor.constraint(equalTo:  self.segmentedControl.bottomAnchor, 
                                                constant:  self.innerLayerSpacing),
            self.tableView.leftAnchor.constraint(equalTo: leftSafeArea),
            self.tableView.rightAnchor.constraint(equalTo: rightSafeArea),
            self.tableView.bottomAnchor.constraint(equalTo: bottomSafeArea),
            
            self.mapView.topAnchor.constraint(equalTo:  self.segmentedControl.bottomAnchor, 
                                              constant:  self.innerLayerSpacing),
            self.mapView.leftAnchor.constraint(equalTo: leftSafeArea),
            self.mapView.rightAnchor.constraint(equalTo: rightSafeArea),
            self.mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    /// 設定 TableView
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let useCells = [CollectionsTableViewCell.self]
        useCells.forEach {
            self.tableView.register($0.self, forCellReuseIdentifier: $0.storyboardIdentifier)
        }
    }
    
    /// 設定 MapView
    private func setupMapView() {
        self.manager.delegate = self
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
    }
    
    private func setupBindings() {
        self.viewModel.onHotelsLoaded = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        self.viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
}

//MARK: - Action
extension CollectionsViewController {
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let selectedOption = SegmentedControlOption(rawValue: sender.selectedSegmentIndex) ?? .list
        switch selectedOption {
        case .list:
            tableView.isHidden = false
            mapView.isHidden = true
            tabBarController?.tabBar.isHidden = false
        case .map:
            self.getUserLocationAndShowHotels()
            mapView.isHidden = false
            tableView.isHidden = true
            tabBarController?.tabBar.isHidden = true
        }
    }
}

//MARK: - Private
extension CollectionsViewController {
    /// 取得使用者位置資訊
    private func getUserLocationAndShowHotels() {
        switch manager.authorizationStatus {
        case .notDetermined:
            self.manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            self.showLocationPermissionAlert()
            self.showHotelsOnMap()
        case .authorizedWhenInUse, .authorizedAlways:
            self.manager.requestLocation() // 只請求一次位置
            self.showHotelsOnMap()
        @unknown default:
            break
        }
    }
    
    /// 顯示旅店於地圖上的位置
    private func showHotelsOnMap() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.viewModel.getHotelAnnotations().forEach { self.mapView.addAnnotation($0) }
        
        if let firstHotel = self.viewModel.getHotelAnnotations().first {
            let region = MKCoordinateRegion(center: firstHotel.coordinate,
                                            latitudinalMeters: 1200, longitudinalMeters: 1200)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    /// 顯示地圖權限未開啟彈窗
    private func showLocationPermissionAlert() {
        let message = "如欲使用此功能，請開啟定位權限\n\n請至\n設定 > 隱私權與安全性 >\n定位服務 > 永許旅社取得您得位置。"
        showAlertClosure(title: "定位權限已關閉", message: message, okBtn: "前往開啟") {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
    }
}

//MARK: - TableView
extension CollectionsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  self.viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CollectionsTableViewCell.self), for: indexPath) as? CollectionsTableViewCell else {
            return UITableViewCell()
        }
        
        if let hotel =  self.viewModel.hotel(at: indexPath) {
            cell.configure(with: hotel)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let hotel =  self.viewModel.hotel(at: indexPath) {
            
            let viewModel = HotelDetailsViewModel(hotel: hotel)
            let vc = HotelDetailsViewController(viewModel: viewModel)
            
            vc.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(vc, animated: true)
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.back))
        }
    }
}

// MARK: - MKMapViewDelegate, CLLocationManagerDelegate
extension CollectionsViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        let region = MKCoordinateRegion(center: location.coordinate, 
                                        latitudinalMeters: 1200, longitudinalMeters: 1200)
        self.mapView.setRegion(region, animated: true)
        self.showHotelsOnMap()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        self.showHotelsOnMap()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }

        let identifier = "HotelAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? HotelAnnotation else { return }
        let hotel = annotation.hotel
        let viewModel = HotelDetailsViewModel(hotel: hotel)
        let vc = HotelDetailsViewController(viewModel: viewModel)
        
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
