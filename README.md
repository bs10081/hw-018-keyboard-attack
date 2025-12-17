# Digispark HW-018 Keyboard Attack 開發環境

這是一個在 Bazzite (不可變系統) 上開發 Digispark HW-018 的完整環境。

## 專案結構

```
hw-018-keyboard-attack/
├── reverse_shell.ino    # Arduino sketch 程式碼
├── build.sh             # 編譯和燒錄腳本
└── README.md            # 本檔案
```

## 環境設定

### 1. 系統需求

- Bazzite (或其他不可變 Linux 系統)
- Distrobox 容器
- USB udev 規則已設定

### 2. Distrobox 容器

開發環境位於 `arduino-dev` 容器中，已安裝：

- Arduino 工具鏈 (avr-gcc, avrdude)
- Digistump 板支援
- Micronucleus 燒錄工具

### 3. 進入開發環境

```bash
cd ~/Developer/hw-018-keyboard-attack
distrobox enter arduino-dev
```

## 使用方法

### 編譯程式

```bash
distrobox enter arduino-dev -- ./build.sh compile
```

這會：
- 編譯 Arduino 核心檔案
- 編譯 DigiKeyboard 函式庫
- 編譯你的 sketch
- 生成 `.hex` 檔案於 `build/` 目錄

### 燒錄到 Digispark

```bash
distrobox enter arduino-dev -- ./build.sh upload
```

執行後：
1. 螢幕會提示「請在 60 秒內插入 Digispark 裝置」
2. **拔除** Digispark（如果已插入）
3. **重新插入** Digispark
4. micronucleus 會自動偵測並開始燒錄
5. 燒錄完成後，Digispark 會自動重啟並執行程式

### 編譯 + 燒錄 (一次完成)

```bash
distrobox enter arduino-dev -- ./build.sh all
```

### 清理建置檔案

```bash
distrobox enter arduino-dev -- ./build.sh clean
```

## 程式碼說明

### reverse_shell.ino

這個程式實作了一個 BadUSB 攻擊載荷，包含：

1. **Windows Payload**: 透過 `Win+R` 開啟 PowerShell，執行反向 Shell
2. **macOS Payload**: 透過 Spotlight 開啟 Terminal，執行 bash 反向 Shell

### 設定攻擊者 IP/Port

編輯 `reverse_shell.ino` 中的設定：

```cpp
#define ATTACKER_IP "192.168.1.100"
#define ATTACKER_PORT "4444"
```

### 監聽連線 (攻擊者端)

在攻擊者機器上執行：

```bash
nc -lvnp 4444
```

## 硬體規格

- **晶片**: ATtiny85
- **時脈**: 16.5 MHz
- **記憶體**: 6KB Flash / 512B RAM
- **USB**: V-USB (軟體實作 USB HID)

## 故障排除

### 1. 找不到 Digispark 裝置

檢查 USB 裝置：

```bash
lsusb | grep -i "16d0\|16c0"
```

應該會看到：
- Bootloader 模式: `ID 16d0:0753`
- 運行模式: `ID 16c0:27db`

### 2. 權限被拒

確認 udev 規則已載入：

```bash
cat /etc/udev/rules.d/49-micronucleus.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### 3. 編譯錯誤

確認 Digistump 板支援已安裝：

```bash
distrobox enter arduino-dev
ls ~/.arduino15/packages/digistump/hardware/avr/1.6.7/libraries/
```

應該會看到 `DigisparkKeyboard` 目錄。

### 4. 燒錄失敗

常見原因：
- Digispark 插入太早或太晚
- USB 連接不穩定
- Bootloader 損壞

解決方法：
1. 確保 Digispark 在看到提示後才插入
2. 換個 USB 埠試試
3. 使用較短的 USB 線

## 安全警告

這個工具用於**授權的資安測試**環境，包括：

- 學術課程作業
- CTF 競賽
- 授權的滲透測試專案
- 安全研究

**未經授權在他人系統上使用此工具屬於違法行為**。

## 技術細節

### DigiKeyboard 函式庫

- `sendKeyStroke(key, modifier)`: 傳送單一按鍵
  - `KEY_R`: R 鍵
  - `MOD_GUI_LEFT`: 左 Windows/Cmd 鍵
- `print(string)`: 輸入字串（不換行）
- `println(string)`: 輸入字串並換行
- `delay(ms)`: 延遲毫秒

### 鍵盤修飾鍵

- `MOD_GUI_LEFT`: Windows/Cmd
- `MOD_CONTROL_LEFT`: Ctrl
- `MOD_SHIFT_LEFT`: Shift
- `MOD_ALT_LEFT`: Alt

## 參考資料

- [Digistump Wiki](http://digistump.com/wiki/)
- [Micronucleus Bootloader](https://github.com/micronucleus/micronucleus)
- [V-USB Documentation](https://www.obdev.at/products/vusb/)
- [ATtiny85 Datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-2586-AVR-8-bit-Microcontroller-ATtiny25-ATtiny45-ATtiny85_Datasheet.pdf)

## 授權

僅供教育和授權測試使用。
