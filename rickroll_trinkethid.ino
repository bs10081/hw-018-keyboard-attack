#include <TrinketHidCombo.h>

// === macOS Rick Roll (使用 TrinketHidCombo - 真正的媒體鍵) ===
// 參考: https://github.com/adafruit/Adafruit-Trinket-USB
// 教學: https://diyusthad.com/2021/07/remote-control-pc-media-player-digispark.html

void setup() {
  TrinketHidCombo.begin(); // 初始化 USB HID
  delay(1000);
}

void loop() {
  // === 步驟 1：調整音量到最大（使用真正的媒體鍵）===
  // MMKEY_VOL_UP = 0xE9 (Consumer Control HID)
  TrinketHidCombo.poll();
  delay(500);

  for(int i = 0; i < 20; i++) {  // 按 20 次確保最大
    TrinketHidCombo.pressMultimediaKey(MMKEY_VOL_UP);
    delay(100);
  }

  TrinketHidCombo.poll();
  delay(500);

  // === 步驟 2：調整亮度到最大 ===
  // 注意: TrinketHidCombo 沒有亮度控制，還是用 F2
  for(int i = 0; i < 16; i++) {
    TrinketHidCombo.pressKey(0, KEYCODE_F2);  // F2 鍵
    delay(50);
    TrinketHidCombo.pressKey(0, 0);  // 釋放鍵
    delay(50);
  }

  TrinketHidCombo.poll();
  delay(800);

  // === 步驟 3：開啟 Spotlight (Cmd+Space) ===
  TrinketHidCombo.pressKey(KEYCODE_MOD_LEFT_GUI, KEYCODE_SPACE);
  delay(50);
  TrinketHidCombo.pressKey(0, 0);
  delay(1000);

  // === 步驟 4：輸入 "Google Chrome" ===
  TrinketHidCombo.print("Google Chrome");
  delay(500);

  // 按 Enter
  TrinketHidCombo.pressKey(0, KEYCODE_ENTER);
  delay(50);
  TrinketHidCombo.pressKey(0, 0);
  delay(4000);  // 等待 Chrome 啟動

  // === 步驟 5：Cmd+L 聚焦網址列 ===
  TrinketHidCombo.pressKey(KEYCODE_MOD_LEFT_GUI, KEYCODE_L);
  delay(50);
  TrinketHidCombo.pressKey(0, 0);
  delay(600);

  // === 步驟 6：輸入 YouTube URL ===
  TrinketHidCombo.print("https://www.youtube.com/watch?v=dQw4w9WgXcQ&autoplay=1");
  delay(300);

  // 按 Enter
  TrinketHidCombo.pressKey(0, KEYCODE_ENTER);
  delay(50);
  TrinketHidCombo.pressKey(0, 0);
  delay(8000);  // 等待頁面載入

  // === 步驟 8：按 F 進入 YouTube 全螢幕 ===
  TrinketHidCombo.pressKey(0, KEYCODE_F);
  delay(50);
  TrinketHidCombo.pressKey(0, 0);
  delay(1000);

  // === 步驟 9：再次確保音量最大 ===
  for(int i = 0; i < 5; i++) {
    TrinketHidCombo.pressMultimediaKey(MMKEY_VOL_UP);
    delay(150);
  }

  // 完成！Never gonna give you up! 🎵
  for(;;) {
    TrinketHidCombo.poll(); // 保持 USB 連線
    delay(100);
  }
}
