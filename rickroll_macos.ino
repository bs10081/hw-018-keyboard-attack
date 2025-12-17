#include "DigiKeyboard.h"

// === macOS Rick Roll 載荷 ===
// 功能：開啟 Safari 並播放 Never Gonna Give You Up (全螢幕、最大音量、最大亮度)

void setup() {
  DigiKeyboard.delay(1000);
}

void loop() {
  // === 步驟 1：調整音量到最大 ===
  // 按住 Shift+Option 再按 F12 可以直接調到最大音量
  for(int i = 0; i < 20; i++) {
    DigiKeyboard.sendKeyStroke(KEY_F12, MOD_SHIFT_LEFT | MOD_ALT_LEFT);
    DigiKeyboard.delay(50);
  }

  DigiKeyboard.delay(300);

  // === 步驟 2：調整亮度到最大 ===
  // F2 增加亮度
  for(int i = 0; i < 20; i++) {
    DigiKeyboard.sendKeyStroke(KEY_F2);
    DigiKeyboard.delay(50);
  }

  DigiKeyboard.delay(500);

  // === 步驟 3：開啟 Spotlight ===
  DigiKeyboard.sendKeyStroke(KEY_SPACE, MOD_GUI_LEFT);
  DigiKeyboard.delay(800);

  // === 步驟 4：輸入 Safari 並開啟 ===
  DigiKeyboard.println("Safari");
  DigiKeyboard.delay(1500);
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(3000); // 等待 Safari 啟動

  // === 步驟 5：輸入 YouTube URL ===
  DigiKeyboard.sendKeyStroke(KEY_L, MOD_GUI_LEFT); // Cmd+L 聚焦網址列
  DigiKeyboard.delay(500);

  DigiKeyboard.println("https://www.youtube.com/watch?v=dQw4w9WgXcQ");
  DigiKeyboard.delay(800);
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(5000); // 等待頁面載入

  // === 步驟 6：點擊播放 (按空白鍵) ===
  DigiKeyboard.sendKeyStroke(KEY_SPACE);
  DigiKeyboard.delay(1000);

  // === 步驟 7：進入全螢幕 ===
  DigiKeyboard.sendKeyStroke(KEY_F, MOD_CONTROL_LEFT | MOD_GUI_LEFT); // Ctrl+Cmd+F 全螢幕
  DigiKeyboard.delay(500);

  // 也可以試試按 F 鍵（YouTube 的全螢幕快捷鍵）
  DigiKeyboard.sendKeyStroke(KEY_F);

  // 完成！永遠不會放棄你 🎵
  for(;;) {}
}
