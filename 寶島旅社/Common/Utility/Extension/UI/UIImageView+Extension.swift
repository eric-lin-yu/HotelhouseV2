//
//  ImageView+Ext.swift
//  CathayBank
//
//  Created by wistronits on 2023/8/11.
//

import UIKit

extension UIImageView {
    private static let imageCache = NSCache<NSString, UIImage>()

    /// async/await 載入圖片
    @discardableResult
    func loadImage(from urlString: String, placeholder: UIImage? = UIImage(named: "iconError")) async -> UIImage? {
        // 檢查快取
        if let cachedImage = UIImageView.imageCache.object(forKey: urlString as NSString) {
            await MainActor.run { self.image = cachedImage }
            return cachedImage
        }

        // 在主執行緒換上佔位圖，避免畫面留白
        await MainActor.run {
            self.image = placeholder
            self.backgroundColor = .systemGray6
        }

        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // 在背景進行耗時的解碼
            guard let image = UIImage(data: data) else { return nil }
            
            UIImageView.imageCache.setObject(image, forKey: urlString as NSString)
            
            await MainActor.run {
                self.image = image
                self.backgroundColor = .clear
            }
            return image
        } catch {
            print("圖片載入失敗: \(error)")
            return nil
        }
    }
    
    /// 載入圖片並帶有淡入動畫
    /// - Parameters:
    ///   - image: 要顯示的圖片目標
    ///   - duration: 動畫持續時間，預設為 0.3 秒
    ///   - completion: 動畫結束後的回呼（選填）
    func setImageWithFade(_ image: UIImage?,
                          duration: TimeInterval = 0.3,
                          completion: ((Bool) -> Void)? = nil) {
        
        // 確保在主執行緒執行 UI 更新
        DispatchQueue.main.async {
            // 先將透明度設為 0
            self.alpha = 0
            self.image = image
            
            // 執行淡入動畫
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: .curveEaseIn,
                           animations: {
                self.alpha = 1
            }, completion: completion)
        }
    }
}

