# Hosts 重導向清理指南

這個專案會將 `moodle.ncnu.edu.tw` 臨時重導向到 Reddit (151.101.1.140)

## ⚠️ 重要提醒

- 這會**修改系統 hosts 檔案**
- 需要**管理員/root 權限**
- **可以輕易還原**（見下方清理步驟）
- 僅供**授權測試環境**使用

## 檔案說明

- `hosts_redirect.ino` - Digispark 載荷
- `cleanup_*.sh` - 各平台的清理腳本

## 使用方式

### 1. 編譯載荷

```bash
cd ~/Developer/hw-018-keyboard-attack
SKETCH_NAME=hosts_redirect distrobox enter arduino-dev -- ./build.sh compile
```

### 2. 燒錄到 Digispark

```bash
SKETCH_NAME=hosts_redirect distrobox enter arduino-dev -- bash -c "
cd /home/bs10081/Developer/hw-018-keyboard-attack
sudo micronucleus --run build/hosts_redirect.hex
"
```

### 3. 測試

將 Digispark 插入目標機器，它會：
1. 嘗試以管理員身份執行
2. 添加一行到 hosts 檔案：`151.101.1.140 moodle.ncnu.edu.tw`
3. 訪問 moodle.ncnu.edu.tw 會被重導向到 Reddit

## 清理方式（移除重導向）

### Windows

**方法 1: PowerShell (管理員)**
```powershell
# 開啟 PowerShell (管理員)
$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
(Get-Content $hostsPath) | Where-Object { $_ -notmatch 'moodle.ncnu.edu.tw' } | Set-Content $hostsPath
```

**方法 2: 手動編輯**
1. 以系統管理員身份開啟記事本
2. 開啟 `C:\Windows\System32\drivers\etc\hosts`
3. 刪除包含 `moodle.ncnu.edu.tw` 的行
4. 儲存

### macOS

**終端機執行：**
```bash
sudo sed -i '' '/moodle.ncnu.edu.tw/d' /etc/hosts
```

或手動編輯：
```bash
sudo nano /etc/hosts
# 刪除包含 moodle.ncnu.edu.tw 的行
# 按 Ctrl+X, Y, Enter 儲存
```

### Linux

**終端機執行：**
```bash
sudo sed -i '/moodle.ncnu.edu.tw/d' /etc/hosts
```

或手動編輯：
```bash
sudo nano /etc/hosts
# 刪除包含 moodle.ncnu.edu.tw 的行
# 按 Ctrl+X, Y, Enter 儲存
```

## 驗證清理

執行以下指令確認已清除：

```bash
# Windows (PowerShell)
Get-Content C:\Windows\System32\drivers\etc\hosts | Select-String "moodle"

# macOS / Linux
cat /etc/hosts | grep moodle
```

應該**沒有任何輸出**

## 技術細節

### Hosts 檔案位置

- **Windows**: `C:\Windows\System32\drivers\etc\hosts`
- **macOS**: `/etc/hosts`
- **Linux**: `/etc/hosts`

### 載荷運作流程

1. **Windows**: Win+R → PowerShell (提升權限) → 添加 hosts 條目
2. **macOS**: Spotlight → Terminal → sudo 添加 hosts 條目
3. **Linux**: Ctrl+Alt+T → Terminal → sudo 添加 hosts 條目

### 限制

- **macOS/Linux**: 需要使用者手動輸入 sudo 密碼
- **Windows**: UAC 可能需要手動點擊確認
- **輸入法**: 如果系統預設非英文輸入法可能失敗

## 改進建議

如果要完全自動化（不需要密碼），可以：

1. **使用已知密碼的測試環境**
2. **修改程式碼包含密碼輸入**（安全風險！）
3. **使用無密碼 sudo 的測試機器**

## 測試檢查清單

- [ ] 編譯成功
- [ ] 燒錄成功
- [ ] 在測試機器上執行
- [ ] 確認 hosts 檔案已修改
- [ ] 測試網址重導向
- [ ] 執行清理腳本
- [ ] 確認 hosts 檔案已還原

## 注意事項

⚠️ **僅在授權的測試環境中使用**
⚠️ **使用後務必清理 hosts 檔案**
⚠️ **不要在生產環境或他人電腦上使用**
