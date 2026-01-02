//
//  CollectionsViewController.swift
//  寶島旅社
//
//  Created by wistronits on 2023/7/28.
//  Copyright © 2023 Eric Lin. All rights reserved.
//

import UIKit

class CollectionsViewController: UIViewController {
    private let viewModel: CollectionsViewModel
    
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
        
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.orangeRed,
                                                 .font: UIFont.systemFont(ofSize: 17)], for: .normal)
        
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
        self.setupSearchView()
        
        self.viewModel.delegate = self
        
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

//MARK: - setup UI
extension CollectionsViewController {
    
    /// 設定 Views
    private func setupViews() {
        view.backgroundColor = .white
        let viewsToAdd: [UIView] = [
            self.searchView,
            self.segmentedControl,
            self.tableView
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
        ])
    }
}

//MARK: - Action
extension CollectionsViewController {
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            tableView.isHidden = false
            tabBarController?.tabBar.isHidden = false
        case 1:
            let viewModel = CollectionsMapViewModel(hotels: self.viewModel.allHotels)
            let mapVC = CollectionsMapViewController(viewModel: viewModel)
            mapVC.modalPresentationStyle = .fullScreen
            
            sender.selectedSegmentIndex = 0
            
            self.present(mapVC, animated: true, completion: nil)
        default:
            break
        }
    }
    
    @objc private func handleSectionToggle(_ sender: UIButton) {
        let section = sender.tag
        self.viewModel.toggleSection(section)
        
        // 使用 reloadSections 帶有動畫效果，體驗更好
        self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        self.viewModel.search(keyword: textField.text ?? "")
    }
    
    @objc private func searchButtonTapped() {
        guard let text = self.searchTextFiled.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.view.showToast(text: "查詢條件未輸入哦")
            return
        }
        
        let count = self.viewModel.search(keyword: text)
        if count == 0 {
            self.view.showToast(text: "找不到相關的旅店哦")
        }
        
        self.searchTextFiled.resignFirstResponder()
    }
}

//MARK: - Private
extension CollectionsViewController {
    
    /// 設定 TableView
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let useCells = [CollectionsTableViewCell.self]
        useCells.forEach {
            self.tableView.register(UINib(nibName: $0.storyboardIdentifier, bundle: Bundle.messageCoreBundle), forCellReuseIdentifier: $0.storyboardIdentifier)
        }
        
    }
    
    /// 設定 searchView
    private func setupSearchView() {
        self.searchTextFiled.delegate = self
        self.searchTextFiled.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // 監聽搜尋按鈕點擊
        self.searchiconBtn.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
}

//MARK: - TableView
extension CollectionsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  self.viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView()
        containerView.backgroundColor = .systemGray6
        
        let button = UIButton(type: .custom)
        let cityName = self.viewModel.titleForSection(section)
        let isCollapsed = self.viewModel.isSectionCollapsed(section)
        
        // 設定標題與箭頭狀態
        let arrow = isCollapsed ? "▶" : "▼"
        button.setTitle("\(arrow)  \(cityName)", for: .normal)
        button.setTitleColor(.sageGreen, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.contentHorizontalAlignment = .left
        button.tag = section
        button.addTarget(self, action: #selector(handleSectionToggle), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: containerView.topAnchor),
            button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: self.spacing),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        return containerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CollectionsTableViewCell.self), for: indexPath) as? CollectionsTableViewCell else {
            return UITableViewCell()
        }
        
        if let hotel = self.viewModel.hotel(at: indexPath) {
            cell.configure(with: hotel)
            cell.delegate = self
        }
        
        return cell
    }
}

//MARK: - CollectionsViewModelDelegate

extension CollectionsViewController: CollectionsViewModelDelegate {
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    func viewModelDidFail() {
        self.showAlert(title: "錯誤訊息", message: "資料取得異常")
    }
}

//MARK: - UITextFieldDelegate
extension CollectionsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 收起鍵盤
        return true
    }
}


// MARK: - CollectionsTableViewCellDelegate
extension CollectionsViewController: CollectionsTableViewCellDelegate {
    
    func didTapEditNote(hotel: Hotel) {
        //TODO: 待實作筆記頁
        self.view.showToast(text: "還沒實作")
    }
    
    func didTapMoreInfo(hotel: Hotel) {
        let viewModel = HotelDetailsViewModel(hotel: hotel)
        let vc = HotelDetailsViewController(viewModel: viewModel)
        
        vc.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(vc, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.back))
    }
    
    func didTapDelete(hotel: Hotel) {
        self.showAlertClosure(title: "確認刪除", message: "確定要將 \(hotel.name) 從收藏中移除嗎？", okBtn: "刪除") {
            // RealmManager 刪除邏輯
            RealmManager.shard?.deleteHotelFromRealm(hotel)
            
            // 重新載入資料
            self.viewModel.loadHotels()
        }
    }
}
