//
//  DataSyncState.swift
//  寶島旅社
//
//  Created by Eric Lin on 2026/1/7.
//  Copyright © 2026 Eric Lin. All rights reserved.
//

enum DataSyncState {
    // 檢查中
    case checking
    // 已是最新
    case upToDate
    // 有新版本
    case needUpdate
    // 檢查失敗
    case error
}
