#!/usr/bin/env python3
"""
遞迴解壓縮 Zip Bomb (42.zip)
會持續解壓所有巢狀的 zip 檔案直到無法再解壓為止
"""

import os
import subprocess
import sys
from pathlib import Path

def extract_recursive(zip_file, password="42", max_depth=10, current_depth=0):
    """
    遞迴解壓縮 zip 檔案

    Args:
        zip_file: zip 檔案路徑
        password: 解壓密碼
        max_depth: 最大遞迴深度（防止無限遞迴）
        current_depth: 當前深度
    """
    if current_depth >= max_depth:
        print(f"⚠️  達到最大深度 {max_depth}，停止遞迴")
        return

    zip_path = Path(zip_file)
    if not zip_path.exists():
        print(f"❌ 檔案不存在: {zip_file}")
        return

    # 建立解壓目錄
    extract_dir = zip_path.parent / zip_path.stem
    extract_dir.mkdir(exist_ok=True)

    print(f"{'  ' * current_depth}📂 解壓 {zip_path.name} -> {extract_dir.name}/")

    # 使用 7z 解壓
    cmd = ["7z", "x", f"-p{password}", "-y", f"-o{extract_dir}", str(zip_path)]
    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        print(f"{'  ' * current_depth}❌ 解壓失敗: {zip_path.name}")
        return

    # 找出所有解壓出來的 zip 檔案
    nested_zips = list(extract_dir.glob("*.zip"))

    if not nested_zips:
        print(f"{'  ' * current_depth}✅ 完成 (無更多 zip 檔)")
        return

    print(f"{'  ' * current_depth}🔍 發現 {len(nested_zips)} 個巢狀 zip 檔")

    # 遞迴處理所有巢狀 zip
    for nested_zip in sorted(nested_zips):
        extract_recursive(nested_zip, password, max_depth, current_depth + 1)

def main():
    if len(sys.argv) < 2:
        print("用法: python3 extract_zipbomb.py <zip檔案> [密碼] [最大深度]")
        print("")
        print("範例:")
        print("  python3 extract_zipbomb.py 42.zip")
        print("  python3 extract_zipbomb.py 42.zip 42 4")
        sys.exit(1)

    zip_file = sys.argv[1]
    password = sys.argv[2] if len(sys.argv) > 2 else "42"
    max_depth = int(sys.argv[3]) if len(sys.argv) > 3 else 10

    print("════════════════════════════════════════════════════")
    print("  Zip Bomb 遞迴解壓工具")
    print("════════════════════════════════════════════════════")
    print(f"檔案: {zip_file}")
    print(f"密碼: {password}")
    print(f"最大深度: {max_depth}")
    print("")
    print("⚠️  警告: 這會產生大量檔案！")
    print("")

    # 確認
    response = input("確定要繼續嗎？(yes/no): ")
    if response.lower() != "yes":
        print("已取消")
        sys.exit(0)

    print("")
    print("開始解壓...")
    print("")

    extract_recursive(zip_file, password, max_depth)

    print("")
    print("════════════════════════════════════════════════════")
    print("  ✅ 完成!")
    print("════════════════════════════════════════════════════")

    # 顯示磁碟使用量
    zip_dir = Path(zip_file).parent
    result = subprocess.run(["du", "-sh", str(zip_dir)], capture_output=True, text=True)
    if result.returncode == 0:
        print(f"總大小: {result.stdout.strip()}")

if __name__ == "__main__":
    main()
