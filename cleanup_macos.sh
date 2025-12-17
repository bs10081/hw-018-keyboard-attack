#!/bin/bash
# macOS Hosts 清理腳本
# 使用方式: chmod +x cleanup_macos.sh && ./cleanup_macos.sh

HOSTS_FILE="/etc/hosts"
DOMAIN="moodle.ncnu.edu.tw"

echo "=== macOS Hosts 清理工具 ==="
echo ""

# 檢查是否有該條目
if grep -q "$DOMAIN" "$HOSTS_FILE" 2>/dev/null; then
    echo "找到 hosts 條目:"
    grep "$DOMAIN" "$HOSTS_FILE"
    echo ""

    echo "需要管理員權限來修改 hosts 檔案..."
    sudo sed -i '' "/$DOMAIN/d" "$HOSTS_FILE"

    if [ $? -eq 0 ]; then
        echo "✓ 已成功移除 $DOMAIN 的重導向"
        echo ""

        # 清除 DNS 快取
        echo "清除 DNS 快取..."
        sudo dscacheutil -flushcache
        sudo killall -HUP mDNSResponder

        echo "✓ 完成！"
    else
        echo "✗ 清理失敗，請檢查權限"
        exit 1
    fi
else
    echo "未找到 $DOMAIN 的 hosts 條目，無需清理"
fi
