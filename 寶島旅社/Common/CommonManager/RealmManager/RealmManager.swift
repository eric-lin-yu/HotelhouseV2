//
//  RealmConfigurator.swift
//  CathayWalletPodTest
//
//  Created by wistronits on 2023/3/29.
//

import Foundation
import RealmSwift
import UIKit

class RealmManager {
    enum RealmError: Error {
        case createRealmObjectFail
    }
    
    // MARK: - Property
    static let shard: RealmManager? = makeSharedInstance()
    
    let sharedRealmObjecgt: Realm
    
    // Realm Data異動調整時，Version記得調整
    private static let schemaVersion: UInt64 = 2
    
    private let realmConfig: Realm.Configuration
    
    private init() throws {
        do {
            self.realmConfig = RealmManager.createConfigure()
            self.sharedRealmObjecgt = try Realm(configuration: self.realmConfig)
        } catch let error as NSError {
            print(("Error opening realm: \(error.localizedDescription)"))
            throw RealmError.createRealmObjectFail
        }
    }
    
    /// 檢索指定物件類型的 Realm 結果叢集
    /// - Parameter objectType: 指定的物件類型。
    /// - Returns: 指定物件類型的 Realm 結果叢集。
    func objects<ObjectType: Object>(_ objectType: ObjectType.Type) -> Results<ObjectType> {
        return self.sharedRealmObjecgt.objects(objectType)
    }
    
    public func reset() {
        self.sharedRealmObjecgt.invalidate()
    }
    
    
    /// 檢查旅店是否已被收藏
    func isHotelFavorited(id: String) -> Bool {
        let realm = self.sharedRealmObjecgt
        return realm.object(ofType: RLM_CollectionsHotels.self, forPrimaryKey: id) != nil
    }
    
    /// 從 Realm 刪除收藏的旅店
    func deleteHotelFromRealm(_ hotel: Hotel) {
        let realm = self.sharedRealmObjecgt
        
        if let hotelToDelete = realm.objects(RLM_CollectionsHotels.self).filter("hotelID == %@", hotel.id).first {
            do {
                try realm.write {
                    realm.delete(hotelToDelete)
                    ResponseHandler.presentAlertHandler(message: "旅店刪除成功")
                }
            } catch {
                ResponseHandler.errorHandler(errorString: "刪除失敗")
            }
        } else {
            ResponseHandler.presentAlertHandler(message: "找不到該筆旅店資料")
        }
    }
    
    /// 點擊按鈕切換收藏狀態
    @discardableResult
    func toggleHotelFavorite(_ hotel: Hotel) -> Bool {
        let realm = self.sharedRealmObjecgt
        var isFavorite = false
        var message = ""

        if let existing = realm.object(ofType: RLM_CollectionsHotels.self, forPrimaryKey: hotel.id) {
            try? realm.write { realm.delete(existing) }
            isFavorite = false
            message = "已取消收藏"
        } else {
            try? realm.write { realm.add(RLM_CollectionsHotels(hotel: hotel)) }
            isFavorite = true
            message = "收藏成功"
        }

        // Top View 來顯示 Toast
        if let topView = UIApplication.shared.topWindow {
            topView.showToast(text: message)
        }

        return isFavorite
    }
    
    /// 取得收藏列表並轉回 Hotel Struct
    func getHotelsFromRealm() -> [Hotel] {
        let results = objects(RLM_CollectionsHotels.self)
        
        return results.map { rlm in
            // 從 List<RLM_HotelImage> 還原回 picture1, 2, 3
            let p1 = rlm.images.count > 0 ? rlm.images[0].url : ""
            let p2 = rlm.images.count > 1 ? rlm.images[1].url : ""
            let p3 = rlm.images.count > 2 ? rlm.images[2].url : ""
            
            return Hotel(
                id: rlm.id,
                name: rlm.name,
                description: rlm.descriptionText,
                region: rlm.region,
                town: rlm.town,
                add: rlm.add,
                zipcode: rlm.zipcode,
                px: rlm.px,
                py: rlm.py,
                hotelClass: HotelClass(rawValue: rlm.hotelClassRawValue) ?? .unknown,
                tel: rlm.tel,
                website: rlm.website,
                totalNumberofRooms: rlm.totalNumberofRooms,
                totalNumberofPeople: rlm.totalNumberofPeople,
                accessibilityRooms: rlm.accessibilityRooms,
                parkingSpace: rlm.parkingSpace,
                parkinginfo: rlm.parkinginfo,
                lowestPrice: rlm.lowestPrice,
                ceilingPrice: rlm.ceilingPrice,
                picture1: p1,
                picture2: p2,
                picture3: p3,
                picdescribe1: rlm.images.count > 0 ? rlm.images[0].imageDescription : "",
                picdescribe2: rlm.images.count > 1 ? rlm.images[1].imageDescription : "",
                picdescribe3: rlm.images.count > 2 ? rlm.images[2].imageDescription : "",
                serviceinfo: rlm.serviceinfo
            )
        }
    }
}

// MARK: - Private

extension RealmManager {
    
    private func write(_ block: (Realm) throws -> Void) throws {
        try self.sharedRealmObjecgt.write {
            try block(sharedRealmObjecgt)
        }
    }
    
    private static func makeSharedInstance() -> RealmManager? {
        do {
            let instance = try RealmManager.init()
            return instance
        } catch {
            // 初始化失敗的錯誤處理邏輯
            print("無法創建 Singleton 實例：\(error)")
            return nil
        }
    }
    
    /// 創建 Realm 資料庫的配置。
    /// - 配置包括：檔案路徑、加密金鑰、模式版本以及資料庫遷移的處理。
    /// - 檔案路徑由 getRealmFolderPath 方法取得，並根據 encryptionKey 的加密 key 來建立對應的資料夾和檔案名稱。
    /// - 加密 key 由 getEncryptionKey 方法取得。
    /// - Returns: Realm 資料庫的配置。
    private static func createConfigure() -> Realm.Configuration {
        let encryptionKey = getEncryptionKey()
        let folderPath = getRealmFolderPath(encryptionKey: encryptionKey)
        
        let config = Realm.Configuration(
            fileURL: URL(fileURLWithPath: folderPath),
            encryptionKey: encryptionKey,
            schemaVersion: schemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
#if DEBUG
                if oldSchemaVersion < schemaVersion {
                    print("\n -------- Realm ReloadData -------- \n")
                    defer { print("\n ---------- END ---------- \n") }
                    print("版本替換： \(oldSchemaVersion) -> \(String(describing: schemaVersion))")
                    // ... 異動調整
                }
#endif
            })
        return config
    }
    
    /// 取得 Realm 資料庫的儲存路徑。
    /// - 資料庫會根據 encryptionKey 來當作資料夾名稱。
    /// - 資料庫的檔案名稱為 "data.realm"，位於由 encryptionKey 建立的資料夾中。
    /// - 如果資料夾不存在，才會嘗試建立。
    /// - Parameter encryptionKey: 長度為 64 個字節的加密 key，用於建立資料夾名稱。
    /// - Returns: 資料庫檔案的完整路徑。
    private static func getRealmFolderPath(encryptionKey: Data) -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderName = encryptionKey.hexString // 使用encryptionKey來建立資料夾名稱
        let folderURL = documentsURL.appendingPathComponent(folderName)
        let filePath = folderURL.appendingPathComponent("data.realm").path
        
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        }
        return filePath
    }
    
    private static func getEncryptionKey() -> Data {
        let deviceUUID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let encryptionKey = deviceUUID.strToSha256().map { UInt8($0) }
        
        // 如果 keyData 長度不足 64 個字元，則使用 0x00 填滿至 64 個字元
        var expandedKeyData = Data(count: 64)
        expandedKeyData.withUnsafeMutableBytes { expandedBytes in
            encryptionKey.withUnsafeBufferPointer { keyBytes in
                expandedBytes.baseAddress?.copyMemory(from: keyBytes.baseAddress!, byteCount: min(64, encryptionKey.count))
            }
        }
        return expandedKeyData
    }
}
