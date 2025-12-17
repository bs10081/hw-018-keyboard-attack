# Digispark HW-018 Keyboard Attack 開發環境

這是一個用於開發 Digispark ATtiny85 BadUSB 攻擊的完整專案，包含多種 HID 鍵盤注入攻擊實作。

## 📋 專案內容

### 🎯 攻擊程式

| 檔案 | 目標系統 | 函式庫 | 說明 |
|------|---------|--------|------|
| `zipbomb_macos.ino` | macOS | TrinketHidCombo | Zip Bomb 攻擊 |
| `zipbomb_macos_digi.ino` | macOS | DigiKeyboard | Zip Bomb (推薦) |
| `zipbomb_linux.ino` | Linux | TrinketHidCombo | Zip Bomb 攻擊 |
| `rickroll_*.ino` | macOS | 多種 | Rick Roll 惡作劇 |
| `reverse_shell*.ino` | 多平台 | DigiKeyboard | 反向 Shell |

### 📚 文件

- **ZIPBOMB_README.md**: Zip Bomb 完整技術文件
- **MACOS_TROUBLESHOOTING.md**: macOS 相容性問題排除
- **HOSTS_REDIRECT_README.md**: DNS 劫持攻擊說明
- **RICKROLL_README.md**: Rick Roll 攻擊說明

### 🔧 工具

- **extract_zipbomb.py**: Python 遞迴解壓工具
- **build_*.sh**: 各種版本的編譯腳本
- **cleanup_*.sh**: 清理腳本

---

## 🚀 快速開始

### 方法 1：直接安裝（推薦）

適用於任何 Linux 發行版：

```bash
# 1. 安裝必要工具
# Ubuntu/Debian
sudo apt install avr-gcc avr-libc avrdude micronucleus

# Fedora
sudo dnf install avr-gcc avr-gcc-c++ avr-libc avrdude

# Arch Linux
sudo pacman -S avr-gcc avr-libc avrdude

# 2. 安裝 Digistump 板支援
arduino --install-boards digistump:avr

# 3. 設定 udev 規則
sudo tee /etc/udev/rules.d/49-micronucleus.rules << 'EOF'
SUBSYSTEM=="usb", ATTR{idVendor}=="16d0", ATTR{idProduct}=="0753", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="16c0", ATTR{idProduct}=="27db", MODE="0666"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger
```

### 方法 2：使用容器（適用於不可變系統）

適用於 Fedora Silverblue、Bazzite 等不可變系統：

```bash
# 建立開發容器
distrobox create --name arduino-dev --image ubuntu:22.04

# 進入容器並安裝工具
distrobox enter arduino-dev
sudo apt update
sudo apt install -y avr-gcc avr-libc avrdude micronucleus

# 安裝 Digistump 板支援
# (參考上方步驟 2)
```

---

## 💣 Zip Bomb 攻擊使用

### macOS 版本（DigiKeyboard - 推薦）

```bash
# 編譯並燒錄
./build_zipbomb_macos_digi.sh all

# 或使用容器
distrobox enter arduino-dev -- ./build_zipbomb_macos_digi.sh all
```

### Linux 版本

```bash
# 編譯並燒錄
./build_zipbomb_linux.sh all

# 或使用容器
distrobox enter arduino-dev -- ./build_zipbomb_linux.sh all
```

**詳細說明**: 參見 [ZIPBOMB_README.md](ZIPBOMB_README.md)

---

## 🎵 其他攻擊

### Rick Roll 攻擊

```bash
./build.sh all
# 詳細說明: RICKROLL_README.md
```

### 反向 Shell

```bash
# 編輯 IP/Port
vim reverse_shell_optimized.ino

# 編譯燒錄
./build.sh all
```

### DNS 劫持

```bash
# 詳細說明: HOSTS_REDIRECT_README.md
```

---

## 🔧 編譯與燒錄

### 基本流程

1. **編譯**
   ```bash
   ./build_*.sh compile
   ```

2. **燒錄**
   ```bash
   ./build_*.sh upload
   # 等待提示後插入 Digispark
   ```

3. **一次完成**
   ```bash
   ./build_*.sh all
   ```

### 使用容器環境

如果使用容器（Distrobox、Podman、Docker）：

```bash
# Distrobox
distrobox enter arduino-dev -- ./build_zipbomb_macos_digi.sh all

# Docker
docker run -it --device=/dev/bus/usb ubuntu:22.04
```

---

## 🛠️ 硬體規格

- **晶片**: ATtiny85
- **時脈**: 16.5 MHz
- **Flash**: 6KB
- **RAM**: 512B
- **USB**: V-USB (軟體實作)

---

## 🐛 故障排除

### 找不到 Digispark

```bash
# 檢查 USB 裝置
lsusb | grep -i "16d0\|16c0"
```

**應該看到**:
- Bootloader: `ID 16d0:0753`
- 運行中: `ID 16c0:27db`

### 權限問題

```bash
# 檢查 udev 規則
cat /etc/udev/rules.d/49-micronucleus.rules

# 重新載入
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### macOS 無法識別

參見 [MACOS_TROUBLESHOOTING.md](MACOS_TROUBLESHOOTING.md)

**快速解決**: 使用 `zipbomb_macos_digi.ino` (DigiKeyboard 版本)

### 編譯錯誤

```bash
# 檢查 Digistump 板支援
ls ~/.arduino15/packages/digistump/hardware/avr/1.6.7/libraries/

# 應該看到 DigisparkKeyboard 目錄
```

---

## ⚠️ 安全警告

本專案僅供**授權的教育與研究**用途：

- ✅ 學術課程作業
- ✅ CTF 競賽練習
- ✅ 授權的滲透測試
- ✅ 安全研究
- ✅ 個人虛擬機測試

❌ **未經授權使用屬違法行為**

---

## 📖 參考資料

### 官方文件
- [Digistump Wiki](http://digistump.com/wiki/)
- [Micronucleus Bootloader](https://github.com/micronucleus/micronucleus)
- [ATtiny85 Datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-2586-AVR-8-bit-Microcontroller-ATtiny25-ATtiny45-ATtiny85_Datasheet.pdf)

### 相關專案
- [iamtraction/ZOD](https://github.com/iamtraction/ZOD) - 42.zip Zip Bomb
- [Adafruit-Trinket-USB](https://github.com/adafruit/Adafruit-Trinket-USB) - TrinketHidCombo

### 安全資源
- [OWASP BadUSB](https://owasp.org/www-community/attacks/BadUSB)
- [HID Attack Vectors (MITRE ATT&CK)](https://attack.mitre.org/techniques/T1091/)

---

## 📄 授權

僅供教育和授權測試使用。

**最後更新**: 2025-12-17
