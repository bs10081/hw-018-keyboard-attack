#!/bin/bash
# Linux Hosts 清理腳本
# 使用方式: chmod +x cleanup_linux.sh && ./cleanup_linux.sh

HOSTS_FILE="/etc/hosts"
DOMAIN="moodle.ncnu.edu.tw"

echo "=== Linux Hosts 清理工具 ==="
echo ""

# 檢查是否有該條目
if grep -q "$DOMAIN" "$HOSTS_FILE" 2>/dev/null; then
    echo "找到 hosts 條目:"
    grep "$DOMAIN" "$HOSTS_FILE"
    echo ""

    echo "需要 root 權限來修改 hosts 檔案..."
    sudo sed -i "/$DOMAIN/d" "$HOSTS_FILE"

    if [ $? -eq 0 ]; then
        echo "✓ 已成功移除 $DOMAIN 的重導向"
        echo ""

        # 清除 DNS 快取 (根據不同的 DNS resolver)
        echo "清除 DNS 快取..."

        # systemd-resolved
        if command -v resolvectl &> /dev/null; then
            sudo resolvectl flush-caches
            echo "  - systemd-resolved 快取已清除"
        fi

        # nscd
        if command -v nscd &> /dev/null; then
            sudo nscd -i hosts
            echo "  - nscd 快取已清除"
        fi

        # dnsmasq
        if systemctl is-active --quiet dnsmasq; then
            sudo systemctl restart dnsmasq
            echo "  - dnsmasq 已重啟"
        fi

        echo ""
        echo "✓ 完成！"
    else
        echo "✗ 清理失敗，請檢查權限"
        exit 1
    fi
else
    echo "未找到 $DOMAIN 的 hosts 條目，無需清理"
fi
