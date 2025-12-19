//  Created by Eric Lin  on 2019/11/1.
//  Copyright © 2019 Eric Lin . All rights reserved.
//

import UIKit

extension UIView {
    /// View add 邊框
    func addRoundBorder(cornerRadius: CGFloat = 15, 
                        borderWidth: CGFloat = 1,
                        borderColor: UIColor = .black,
                        backgroundColor: UIColor = .white) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        self.backgroundColor = backgroundColor
    }
    
    public class func loadViewFromNib<T: UIView>(viewType: T.Type) -> T {
        return Bundle.main.loadNibNamed(String(describing: viewType), owner: nil, options: nil)?.first as! T
    }
    
    public class func loadViewFromNib() -> Self {
        return loadViewFromNib(viewType: self)
    }
    
    func setBackgroundGradient(gradientColors: [CGColor]) {
        setBackgroundGradient(gradientColors: gradientColors, frame: self.bounds)
    }
    
    func setBackgroundGradient(gradientColors: [CGColor], frame: CGRect) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.colors = gradientColors
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    /// 顯示帶有指定文字、圓角半徑、標籤文字大小和垂直內邊距的 Toast 訊息。
    ///
    /// - Parameters:
    ///   - text: 要在 Toast 中顯示的文字。
    ///   - cornerRadius: Toast 視圖的圓角半徑。
    ///   - labelTextSize: Toast 中文本標籤的字型大小。
    ///   - verticalPadding: Toast 標籤的垂直內邊距（上下）。
    func showToast(text: String, cornerRadius: Double = 5.0, labelTextSize: CGFloat = 15.0, verticalPadding: CGFloat = 16.0) {
        hideToast()
        
        let rect = UIScreen.main.bounds
        let textSize = text.sizeOfString(usingFont: UIFont.systemFont(ofSize: labelTextSize))
        let labelWidth = textSize.width + 21.0 * 2
        let labelHeight = textSize.height + verticalPadding * 2
        
        let toastLabel = ToastLabel(frame: CGRect(x: (rect.width - labelWidth) / 2.0,
                                                  y: (rect.height - labelHeight - 44.0) / 2.0,
                                                  width: labelWidth,
                                                  height: labelHeight))
        toastLabel.text = text
        toastLabel.cornerRadius = CGFloat(cornerRadius)
        toastLabel.labelTextSize = labelTextSize

        addSubview(toastLabel)
        
        UIView.animate(withDuration: 2.0, delay: 2.0, animations: {
            toastLabel.alpha = 0.0
        }, completion: { complete in
            toastLabel.removeFromSuperview()
        })
    }

    
    func hideToast() {
        for view in self.subviews {
            if view is ToastLabel {
                view.removeFromSuperview()
            }
        }
    }
    
    /// 左右震動動畫（用於錯誤提醒）
    func shake(count: Float = 3, for duration: TimeInterval = 0.3, withTranslation translation: CGFloat = 8) {
        // 1. 視覺上的震動
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.repeatCount = count
        animation.duration = duration / TimeInterval(animation.repeatCount)
        animation.values = [-translation, translation]
        animation.autoreverses = true
        self.layer.add(animation, forKey: "shake")
        
        // 2. 觸覺上的震動 (Taptic Feedback)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}
