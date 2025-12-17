# Digispark HW-018 開發指南 - 跨平台編譯與燒錄

本專案支援在 **Bazzite**、**macOS** 和 **Linux** 上開發 Digispark ATtiny85。

## 📋 目錄

- [硬體需求](#硬體需求)
- [Bazzite / Fedora Silverblue 設定](#bazzite--fedora-silverblue-設定)
- [macOS 設定](#macos-設定)
- [Linux (Ubuntu/Debian) 設定](#linux-ubuntudebian-設定)
- [專案說明](#專案說明)
- [編譯與燒錄](#編譯與燒錄)

---

## 硬體需求

- Digispark ATtiny85 開發板 (HW-018)
- USB 線（或直接插入 USB 埠）

---

## Bazzite / Fedora Silverblue 設定

由於系統不可變，需要使用 Distrobox 容器。

### 1. 設定 USB udev 規則

```bash
cat << 'EOF' | sudo tee /etc/udev/rules.d/49-micronucleus.rules
# Digispark Bootloader (Micronucleus)
SUBSYSTEM=="usb", ATTR{idVendor}=="16d0", ATTR{idProduct}=="0753", MODE="0666"
# Digispark running
SUBSYSTEM=="usb", ATTR{idVendor}=="16c0", ATTR{idProduct}=="27db", MODE="0666"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger
```

### 2. 建立 Distrobox 容器

```bash
distrobox create --name arduino-dev --image ubuntu:24.04
distrobox enter arduino-dev
```

### 3. 在容器內安裝工具

```bash
sudo apt-get update
sudo apt-get install -y git gcc make gcc-avr avr-libc avrdude libusb-dev

# 安裝 micronucleus
cd /tmp
git clone https://github.com/micronucleus/micronucleus.git
cd micronucleus/commandline
make
sudo cp micronucleus /usr/local/bin/

# 安裝 Digistump 板支援
mkdir -p ~/.arduino15/packages/digistump/hardware/avr
cd ~/.arduino15/packages/digistump/hardware/avr
wget -q https://github.com/digistump/DigistumpArduino/releases/download/1.6.7/digistump-avr-1.6.7.zip
unzip -q digistump-avr-1.6.7.zip
mv digistump-avr-1.6.7 1.6.7

# 安裝 TrinketHidCombo (可選)
cd /tmp
git clone https://github.com/adafruit/Adafruit-Trinket-USB.git
mkdir -p ~/Arduino/libraries
cp -r Adafruit-Trinket-USB/TrinketHidCombo ~/Arduino/libraries/
```

### 4. 編譯和燒錄

```bash
cd ~/hw-018-keyboard-attack

# 編譯 DigiKeyboard 版本
SKETCH_NAME=rickroll_macos_f_keys ./build.sh compile

# 編譯 TrinketHidCombo 版本
./build_trinket.sh compile

# 燒錄（需要 sudo）
distrobox enter arduino-dev -- sudo micronucleus --run build/rickroll_macos_f_keys.hex
```

---

## macOS 設定

### 1. 安裝 Homebrew（如未安裝）

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. 安裝開發工具

```bash
# 安裝 AVR 工具鏈
brew tap osx-cross/avr
brew install avr-gcc avrdude

# 安裝 micronucleus
brew install micronucleus
```

### 3. 安裝 Digistump 板支援

```bash
mkdir -p ~/Library/Arduino15/packages/digistump/hardware/avr
cd ~/Library/Arduino15/packages/digistump/hardware/avr
curl -L -o digistump-avr-1.6.7.zip https://github.com/digistump/DigistumpArduino/releases/download/1.6.7/digistump-avr-1.6.7.zip
unzip digistump-avr-1.6.7.zip
mv digistump-avr-1.6.7 1.6.7
rm digistump-avr-1.6.7.zip
```

### 4. 安裝 TrinketHidCombo（可選）

```bash
mkdir -p ~/Documents/Arduino/libraries
cd /tmp
git clone https://github.com/adafruit/Adafruit-Trinket-USB.git
cp -r Adafruit-Trinket-USB/TrinketHidCombo ~/Documents/Arduino/libraries/
```

### 5. 修改編譯腳本路徑

編輯 `build.sh` 和 `build_trinket.sh`，將路徑改為：

```bash
# macOS 路徑
DIGISTUMP_PATH="$HOME/Library/Arduino15/packages/digistump/hardware/avr/1.6.7"
TRINKET_LIB="$HOME/Documents/Arduino/libraries/TrinketHidCombo"
```

### 6. 編譯和燒錄

```bash
cd ~/hw-018-keyboard-attack

# 編譯
./build.sh compile

# 燒錄
micronucleus --run build/rickroll_macos_f_keys.hex
```

---

## Linux (Ubuntu/Debian) 設定

### 1. 設定 USB 權限

```bash
sudo tee /etc/udev/rules.d/49-micronucleus.rules << 'EOF'
SUBSYSTEM=="usb", ATTR{idVendor}=="16d0", ATTR{idProduct}=="0753", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="16c0", ATTR{idProduct}=="27db", MODE="0666"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger
```

### 2. 安裝開發工具

```bash
sudo apt-get update
sudo apt-get install -y git gcc make gcc-avr avr-libc avrdude libusb-dev
```

### 3. 安裝 micronucleus

```bash
cd /tmp
git clone https://github.com/micronucleus/micronucleus.git
cd micronucleus/commandline
make
sudo cp micronucleus /usr/local/bin/
```

### 4. 安裝 Digistump 板支援

```bash
mkdir -p ~/.arduino15/packages/digistump/hardware/avr
cd ~/.arduino15/packages/digistump/hardware/avr
wget https://github.com/digistump/DigistumpArduino/releases/download/1.6.7/digistump-avr-1.6.7.zip
unzip digistump-avr-1.6.7.zip
mv digistump-avr-1.6.7 1.6.7
rm digistump-avr-1.6.7.zip
```

### 5. 安裝 TrinketHidCombo（可選）

```bash
mkdir -p ~/Arduino/libraries
cd /tmp
git clone https://github.com/adafruit/Adafruit-Trinket-USB.git
cp -r Adafruit-Trinket-USB/TrinketHidCombo ~/Arduino/libraries/
```

### 6. 編譯和燒錄

```bash
cd ~/hw-018-keyboard-attack

# 編譯
./build.sh compile

# 燒錄
sudo micronucleus --run build/rickroll_macos_f_keys.hex
```

---

## 專案說明

### 可用的載荷 (Payloads)

#### 1. Rick Roll 系列

- **`rickroll_macos_f_keys.ino`** - 使用 F 鍵控制音量（需系統設定）
- **`rickroll_macos_fixed.ino`** - 優化版本
- **`rickroll_trinkethid.ino`** - 使用 TrinketHidCombo（真正的媒體鍵）

#### 2. Hosts 重導向

- **`hosts_redirect.ino`** - 修改 hosts 檔案重導向網域

#### 3. 反向 Shell

- **`reverse_shell.ino`** - 原始版本（RAM 不足）
- **`reverse_shell_optimized.ino`** - 優化版本（使用 PROGMEM）

### 編譯腳本

- **`build.sh`** - 編譯 DigiKeyboard 專案
- **`build_trinket.sh`** - 編譯 TrinketHidCombo 專案

### 清理腳本

- **`cleanup_windows.ps1`** - Windows hosts 清理
- **`cleanup_macos.sh`** - macOS hosts 清理
- **`cleanup_linux.sh`** - Linux hosts 清理

---

## 編譯與燒錄

### 方法 1：使用編譯腳本

```bash
# 指定要編譯的 sketch
SKETCH_NAME=rickroll_macos_f_keys ./build.sh compile

# 燒錄
sudo micronucleus --run build/rickroll_macos_f_keys.hex
```

### 方法 2：使用 Arduino IDE

1. 開啟 Arduino IDE
2. 檔案 → 偏好設定 → 額外的板管理員網址：
   ```
   http://digistump.com/package_digistump_index.json
   ```
3. 工具 → 板子 → 板子管理員 → 搜尋 "Digistump AVR Boards" → 安裝
4. 工具 → 板子 → Digispark (Default - 16.5mhz)
5. 開啟 .ino 檔案
6. 上傳（會提示插入 Digispark）

---

## 故障排除

### 找不到 Digispark

```bash
# 檢查 USB 裝置
lsusb | grep -E "16d0|16c0"

# 應該看到：
# ID 16d0:0753 MCS Digistump Digispark Bootloader (插入後 5 秒內)
# ID 16c0:27db Van Ooijen Technische Informatica (正常運行)
```

### 權限被拒

```bash
# Linux/Bazzite
sudo micronucleus --run build/your_sketch.hex

# macOS（通常不需要 sudo）
micronucleus --run build/your_sketch.hex
```

### 編譯錯誤

```bash
# 確認路徑正確
ls ~/.arduino15/packages/digistump/hardware/avr/1.6.7/

# 重新安裝 Digistump 板支援
rm -rf ~/.arduino15/packages/digistump
# 重新執行安裝步驟
```

---

## 授權與免責聲明

⚠️ **僅供教育和授權測試使用**

本專案包含的載荷僅用於：
- 學術課程作業
- CTF 競賽
- 授權的滲透測試
- 安全研究

未經授權在他人系統上使用屬於違法行為。使用者需自行承擔法律責任。

---

## 參考資料

- [Digistump Wiki](http://digistump.com/wiki/)
- [Micronucleus Bootloader](https://github.com/micronucleus/micronucleus)
- [Adafruit TrinketHidCombo](https://github.com/adafruit/Adafruit-Trinket-USB)
- [ATtiny85 Datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-2586-AVR-8-bit-Microcontroller-ATtiny25-ATtiny45-ATtiny85_Datasheet.pdf)

---

**🎓 教育價值**：本專案展示了 BadUSB 攻擊原理、HID 鍵盤模擬和物理安全的重要性。
