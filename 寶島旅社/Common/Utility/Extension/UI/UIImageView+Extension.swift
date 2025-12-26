//
//  ImageView+Ext.swift
//  CathayBank
//
//  Created by wistronits on 2023/8/11.
//

import UIKit

extension UIImageView {
    func loadUrlImage(urlString: String, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let data = data, let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    completion(.success(nil))
                }
            }
        }.resume()
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

