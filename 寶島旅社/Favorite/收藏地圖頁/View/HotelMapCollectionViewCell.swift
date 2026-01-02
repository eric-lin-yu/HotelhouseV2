import UIKit
import CoreLocation

class HotelMapCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var hotelImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.hotelImageView.image = UIImage(named: "iconLoading")
        self.nameLabel.text = nil
        self.addressLabel.text = nil
        self.distanceLabel.text = nil
    }

    private func setupUI() {
        self.containerView.layer.cornerRadius = 12
        self.hotelImageView.layer.cornerRadius = 8
        self.hotelImageView.contentMode = .scaleAspectFill
        
        self.distanceLabel.textColor = .orangeRed
        self.distanceLabel.font = .systemFont(ofSize: 13, weight: .medium)
    }

    /// 配置 Cell 資料
    /// - Parameters:
    ///   - hotel: 旅宿資料
    ///   - userLocation: 使用者當前位置 (若無則顯示未知)
    func configure(with hotel: Hotel, userLocation: CLLocation?) {
        self.nameLabel.text = hotel.name
        
        // 顯示 縣市 / 地區
        let region = hotel.region ?? ""
        let town = hotel.town ?? ""
        self.addressLabel.text = "\(region) / \(town)"
        
        // 計算距離
        if let userLoc = userLocation {
            let hotelLoc = CLLocation(latitude: hotel.py, longitude: hotel.px)
            let distanceInMeters = userLoc.distance(from: hotelLoc)
            let distanceInKm = distanceInMeters / 1000
            self.distanceLabel.text = String(format: "距離 %.1f 公里", distanceInKm)
        } else {
            self.distanceLabel.text = "距離未知"
        }
        
        // 圖片載入
        let imageUrl = hotel.images.first?.url ?? ""

        Task {
            let image = await hotelImageView.loadImage(from: imageUrl)
            self.hotelImageView.image = image ?? UIImage(named: "iconError")
        }
    }
}
