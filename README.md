# 寶島旅社 V2 (Hotelhouse-V2)

[![Platform](https://img.shields.io/badge/Platform-iOS%2015.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org/)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

### 📌 專案簡介
本專案為資策會結業作品「寶島旅社」的全面升級版。\
目標在於補齊前版功能不足之處，並導入實務開發中的 **MVVM 架構**、**Dependency Injection (DI)**\
**單元化重構** 經驗，提升程式碼的可維護性與擴充性。

---

## 🛠 技術棧與架構 (Tech Stack)
- **架構模式**: MVVM (Model-View-ViewModel)
- **UI 佈局**: Storyboard / XIB / Auto Layout / Code-base UI (Collections 頁面)
- **資料持久化**: Realm Swift
- **相依性管理**: Swift Package Manager (SPM)
- **地圖服務**: MapKit / CoreLocation / Google Maps URL Schemes
- **第三方套件**: 
  - `SkeletonView`: 用於 Loading 狀態的骨架屏效果
  - `Realm`: 用於本地收藏管理

---

## 📖 資料來源
- 使用 [政府公開平台 - 旅館民宿-觀光資訊資料庫](https://data.gov.tw/dataset/7780) API。
- **動態更新**: 2025-12-19 已移除舊版靜態 JSON，全面恢復實時 API 串接。
- *備註: 現有 GIF 動圖僅供學術研究示意使用，後續將進行替換以避侵權。*

---

## 📱 功能模組說明

### 1. 首頁 (FrontPageViewController)
- **核心組件**: `UITableView` 搭配多樣化 `UITableViewCell`。
- **視覺體驗**: 導入 Skeleton Screen 優化資料載入時的感受。
- **搜尋功能**: 客製化 Navigation 功能區，支援搜尋視圖切換。

### 2. 旅店介紹頁 (HotelDetailViewController)
- **多型 Cell 設計**: 使用 `enum HotelDetailType` 區分內容：
  - `.hotelImage`: 多圖輪播
  - `.hotelDetails`: 基本資訊與電話、網頁外連
  - `.hotelDescription`: 詳細描述
  - `.hotelExtra`: 設備與服務細節
  - `.hotelMap`: **互動式地圖預覽**（點選可進入 `HotelLocationViewController`）。

### 3. 地圖詳情頁 (HotelLocationViewController)
- **頁面重構**: 原 `HotelDetailMapViewController` 語意化更名。
- **路徑規劃**: 實作 `MKDirections` 計算使用者與旅店間的行車路線，並以橘色 Polyline 渲染。
- **導航整合**: 支援 Apple Maps 與 Google Maps 選單式跳轉導航。

### 4. 收藏模組 (CollectionsViewController)
- **純代碼實作**: 捨棄 Storyboard，提升 UI 靈活度。
- **資料分組**: 根據 `City` 進行資料分組 (Section Title)。
- **雙模式切換**: 支援「列表」與「地圖」顯示模式。

---

## 🚧 開發進度與 TODO
- [x] 移除API相關套件 - alamofire、swiftJson，改用原生方式
- [x] 因應API架構調整，調整下行結構。
- [x] 首頁(FrontPageViewController)、旅店介紹頁(HotelDetailViewController)、地圖詳情頁(HotelLocationViewController)調整為 MVVM 架構
- [x] 修正 XIB 初始化時的 `nibName` 指向與閃退問題。
- [x] 實作地圖 User Location 藍點顯示與區域縮放。
- [x] **客製化 TabBar**: 開發專屬地圖模式的切換 TabBar。
- [ ] **地圖頁面整合**: 整合 `HotelLocationViewController` 與 `MapSearchViewController`，共用地圖底層組件。
- [ ] **收藏頁面重構**: CollectionsViewController 調整為 MVVM 架構，並完善整體功能
- [ ] **收藏連動**: 實作詳細頁收藏按鈕與 Realm 資料的即時雙向綁定。
- [ ] **關於頁面重構**: AboutViewController 調整為 MVVM 架構，並新增設定相關功能

---

## 📈 系統架構圖 (重構中)



---

## 👨‍💻 作者
**Eric Lin** - 結業作品升級計劃：從「能跑」優化到「專業」。
- 致力於 clean code 與架構設計的實踐。
