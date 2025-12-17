#!/bin/bash
# Windows Hosts 清理腳本 (PowerShell)
# 使用方式: 以管理員身份執行 PowerShell，然後執行此腳本

$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$domain = "moodle.ncnu.edu.tw"

Write-Host "=== Windows Hosts 清理工具 ===" -ForegroundColor Green
Write-Host ""

# 檢查是否有該條目
$hasEntry = Get-Content $hostsPath | Select-String $domain

if ($hasEntry) {
    Write-Host "找到 hosts 條目:" -ForegroundColor Yellow
    Write-Host $hasEntry
    Write-Host ""

    # 移除包含該域名的行
    (Get-Content $hostsPath) | Where-Object { $_ -notmatch $domain } | Set-Content $hostsPath

    Write-Host "已成功移除 $domain 的重導向" -ForegroundColor Green
    Write-Host ""

    # 清除 DNS 快取
    Write-Host "清除 DNS 快取..." -ForegroundColor Cyan
    ipconfig /flushdns

} else {
    Write-Host "未找到 $domain 的 hosts 條目，無需清理" -ForegroundColor Gray
}

Write-Host ""
Write-Host "完成！" -ForegroundColor Green
