//
//  HotelDetailCollectionTableViewCell.swift
//  寶島旅社
//
//  Created by Eric Lin on 2022/11/4.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit

class HotelDetailCollectionTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.isPagingEnabled = true
        }
    }
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var images: [HotelImage] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        setupCollectionView()
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 註冊 Cell
        collectionView.register(HotelImageCollectionViewCell.self,
                                forCellWithReuseIdentifier: HotelImageCollectionViewCell.className)
        
        // 設定 Layout
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
    }

    func configure(with images: [HotelImage]) {
        self.images = images
        self.pageControl.numberOfPages = images.count
        self.collectionView.reloadData()
        self.collectionView.setContentOffset(.zero, animated: false)
    }
}

// MARK: - CollectionView DataSource & Delegate
extension HotelDetailCollectionTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.isEmpty ? 1 : self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HotelImageCollectionViewCell.className, for: indexPath) as! HotelImageCollectionViewCell
        
        if self.images.isEmpty {
            cell.configure(with: nil)
        } else {
            cell.configure(with: images[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

// MARK: - ScrollView Delegate
extension HotelDetailCollectionTableViewCell: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width + 0.5)
        pageControl.currentPage = page
    }
}
