//
//  Data+Extension.swift
//  CathayWalletPodTest
//
//  Created by wistronits on 2023/2/13.
//

import Foundation

extension Data {
    var hexString: String {
        return map { String(format: "%02x", $0) }.joined()
    }
    
    init?(hexString: String) {
        let length = hexString.count / 2
        var data = Data(capacity: length)
        for i in 0..<length {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var byte = UInt8(bytes, radix: 16) {
                data.append(&byte, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
    
    /// 將 Data 轉換為美化格式的 JSON 字串，用於日誌輸出。
    var prettyJsonString: String {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
              let prettyPrintedString = String(data: data, encoding: .utf8) else {
            return String(data: self, encoding: .utf8) ?? "Invalid Data"
        }
        return prettyPrintedString
    }
}
