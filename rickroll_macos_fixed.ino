#include "DigiKeyboard.h"

// === macOS Rick Roll 載荷 (修正版) ===
// 根據 2024 年 macOS 和 YouTube 的實際行為優化

void setup() {
  DigiKeyboard.delay(1000);
}

void loop() {
  // === 步驟 1：調整音量到最大 ===
  // F12 = 音量增加，需要按很多次才能到最大
  // 參考: https://support.apple.com/en-ge/102650
  DigiKeyboard.delay(500);
  for(int i = 0; i < 50; i++) {
    DigiKeyboard.sendKeyStroke(KEY_F12); // 不加 Shift+Option，用正常增量
    DigiKeyboard.delay(30);
  }

  DigiKeyboard.delay(500);

  // === 步驟 2：調整亮度到最大 ===
  // F2 = 亮度增加
  for(int i = 0; i < 50; i++) {
    DigiKeyboard.sendKeyStroke(KEY_F2);
    DigiKeyboard.delay(30);
  }

  DigiKeyboard.delay(800);

  // === 步驟 3：開啟 Spotlight ===
  DigiKeyboard.sendKeyStroke(KEY_SPACE, MOD_GUI_LEFT);
  DigiKeyboard.delay(1000);

  // === 步驟 4：輸入 Safari 並開啟 ===
  DigiKeyboard.println("Safari");
  DigiKeyboard.delay(500);
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(4000); // 等待 Safari 完全啟動

  // === 步驟 5：輸入 YouTube URL (帶 autoplay 和 mute) ===
  DigiKeyboard.sendKeyStroke(KEY_L, MOD_GUI_LEFT); // Cmd+L 聚焦網址列
  DigiKeyboard.delay(600);

  // 使用 autoplay=1&mute=1 確保自動播放
  // 參考: https://developers.google.com/youtube/player_parameters
  DigiKeyboard.println("https://www.youtube.com/watch?v=dQw4w9WgXcQ&autoplay=1&mute=1");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(8000); // 等待頁面完全載入和影片開始播放

  // === 步驟 6：取消靜音 ===
  // YouTube 鍵盤快捷鍵 'm' = 切換靜音
  // 參考: https://support.google.com/youtube/answer/7631406
  // DigiKeyboard.sendKeyStroke(KEY_M);
  // DigiKeyboard.delay(500);

  // === 步驟 7：YouTube 全螢幕 ===
  // YouTube 鍵盤快捷鍵 'f' = 切換全螢幕
  DigiKeyboard.sendKeyStroke(KEY_F);
  DigiKeyboard.delay(1000);


  // 完成！Never gonna give you up! 🎵
  for(;;) {}
}
