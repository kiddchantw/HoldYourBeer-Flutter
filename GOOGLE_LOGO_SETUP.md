# Google Logo 設定指南

為了在 Google 登入按鈕上顯示 Google Logo，您需要添加 Google Logo 圖片檔案。

## 圖片規格

- **檔案名稱**: `google_logo.png`
- **建議尺寸**: 96x96 px 或更高（會自動縮放到 24x24）
- **格式**: PNG（透明背景）
- **位置**: `assets/images/google_logo.png`

## 取得 Google Logo

### 方法 1: 從 Google Brand Resource Center 下載（推薦）

1. 前往 [Google Brand Resource Center](https://about.google/brand-resources/)
2. 下載官方的 Google "G" Logo（彩色版本）
3. 選擇 PNG 格式，透明背景
4. 重新命名為 `google_logo.png`
5. 放置到 `assets/images/` 目錄

### 方法 2: 使用 CDN 連結（臨時測試用）

如果您只是想先測試功能，可以使用以下 CDN 連結：

```
https://developers.google.com/identity/images/g-logo.png
```

但請注意：生產環境建議使用本地圖片資源。

### 方法 3: 使用內建替代方案

如果沒有添加 `google_logo.png` 圖片，應用程式會自動顯示一個替代的 "G" 字母按鈕（漸層背景）。這是一個備用方案，但建議還是使用官方 Logo 以獲得更好的使用者體驗。

## 安裝步驟

1. **下載 Google Logo**（見上方方法）

2. **建立 assets/images 目錄**（如果還沒有）
   ```bash
   mkdir -p assets/images
   ```

3. **複製圖片到專案**
   ```bash
   cp /path/to/google_logo.png assets/images/
   ```

4. **確認 pubspec.yaml 已設定**
   `pubspec.yaml` 應該已經包含以下設定：
   ```yaml
   flutter:
     assets:
       - assets/images/
   ```

5. **重新執行 Flutter**
   ```bash
   flutter pub get
   flutter run
   ```

## 驗證設定

執行應用程式後：
1. 打開登入或註冊畫面
2. 捲動到底部，應該會看到 "使用 Google 帳號登入" 按鈕
3. 按鈕上應該顯示 Google "G" Logo

如果看到藍紅漸層的 "G" 字母，表示圖片載入失敗，正在使用備用方案。

## Google 品牌指南遵循

使用 Google Logo 時，請遵守 [Google Brand Guidelines](https://developers.google.com/identity/branding-guidelines)：

- ✅ 使用官方提供的 Logo
- ✅ 保持 Logo 的完整性，不要變形
- ✅ 確保 Logo 周圍有足夠的留白
- ❌ 不要修改 Logo 的顏色
- ❌ 不要旋轉或傾斜 Logo
- ❌ 不要在 Logo 上添加陰影或特效

## 替代方案

如果您無法或不想使用 Google Logo，可以：

1. **使用純文字按鈕**：移除圖片元件，只保留文字
2. **使用 Icon 字體**：使用 Material Icons 的相關圖示
3. **使用內建替代**：保持現狀，使用程式碼中的 errorBuilder 替代方案

---

## 常見問題

### Q: 我可以使用 SVG 格式嗎？
A: 可以，但需要額外的 `flutter_svg` 套件。目前實作使用 PNG 格式較為簡單。

### Q: 圖片顯示不出來怎麼辦？
A: 檢查以下幾點：
1. 檔案路徑是否正確：`assets/images/google_logo.png`
2. `pubspec.yaml` 中是否包含 assets 設定
3. 是否執行了 `flutter pub get`
4. 清除快取並重新編譯：`flutter clean && flutter pub get && flutter run`

### Q: 可以使用其他名稱嗎？
A: 可以，但需要修改 `lib/features/auth/widgets/google_sign_in_button.dart` 中的圖片路徑。

---

如有任何問題，請參考 [Flutter Assets 文件](https://docs.flutter.dev/ui/assets-and-images)。
