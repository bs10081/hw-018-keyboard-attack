#include "DigiKeyboard.h"

// === macOS Rick Roll (使用 F 鍵版本) ===
// 適用於 F 鍵預設為媒體鍵的 Mac（大多數較新的 Mac）

void setup() {
  DigiKeyboard.delay(1000);
}

void loop() {
  // === 步驟 1：調整音量到最大 ===
  // 在大多數 Mac 上，F12 預設為音量增加（不需按 Fn）
  DigiKeyboard.delay(500);
  for(int i = 0; i < 16; i++) {  // macOS 有 16 個音量級別
    DigiKeyboard.sendKeyStroke(KEY_F12);
    DigiKeyboard.delay(100);  // 增加延遲確保每次都生效
  }

  DigiKeyboard.delay(500);

  // === 步驟 2：調整亮度到最大 ===
  // F2 預設為亮度增加
  for(int i = 0; i < 16; i++) {  // macOS 有 16 個亮度級別
    DigiKeyboard.sendKeyStroke(KEY_F2);
    DigiKeyboard.delay(100);
  }

  DigiKeyboard.delay(800);

  // === 步驟 3：開啟 Spotlight ===
  DigiKeyboard.sendKeyStroke(KEY_SPACE, MOD_GUI_LEFT);
  DigiKeyboard.delay(1000);

  // === 步驟 4：輸入 Chrome 並開啟 ===
  DigiKeyboard.println("Google Chrome");
  DigiKeyboard.delay(500);
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(4000);

  // === 步驟 5：輸入 YouTube URL (帶 autoplay，不帶 mute) ===
  DigiKeyboard.sendKeyStroke(KEY_L, MOD_GUI_LEFT);
  DigiKeyboard.delay(600);

  // 只用 autoplay=1，不用 mute
  // 現代瀏覽器可能會阻擋，但試試看
  DigiKeyboard.println("https://www.youtube.com/watch?v=dQw4w9WgXcQ&autoplay=1");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(8000);

  // === 步驟 6：點擊播放（如果沒有自動播放）===
  // 點擊影片區域（模擬滑鼠點擊的替代方案：按 K 或 Space）
  DigiKeyboard.sendKeyStroke(KEY_K);  // YouTube 的播放/暫停鍵
  DigiKeyboard.delay(500);

  // === 步驟 7：YouTube 全螢幕 ===
  DigiKeyboard.sendKeyStroke(KEY_F);
  DigiKeyboard.delay(1000);

  // === 步驟 8：再次確保音量最大 ===
  for(int i = 0; i < 5; i++) {
    DigiKeyboard.sendKeyStroke(KEY_F12);
    DigiKeyboard.delay(150);
  }

  // 完成！
  for(;;) {}
}
