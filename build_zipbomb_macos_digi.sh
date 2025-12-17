#!/bin/bash
# Zip Bomb macOS DigiKeyboard 版本編譯腳本
# 使用 DigiKeyboard 函式庫以獲得更好的 macOS 相容性

set -e

SKETCH_NAME="zipbomb_macos_digi"
SKETCH_PATH="$(pwd)/${SKETCH_NAME}.ino"
BUILD_DIR="$(pwd)/build_zipbomb_macos_digi"

# 檢查原始檔案
if [ ! -f "$SKETCH_PATH" ]; then
    echo "❌ 錯誤: 找不到 ${SKETCH_NAME}.ino"
    exit 1
fi

# Digistump 路徑
DIGISTUMP_PATH="$HOME/.arduino15/packages/digistump/hardware/avr/1.6.7"
DIGISPARK_CORE="${DIGISTUMP_PATH}/cores/tiny"
DIGISPARK_VARIANT="${DIGISTUMP_PATH}/variants/digispark"
DIGISPARK_LIBS="${DIGISTUMP_PATH}/libraries"

# 編譯器設定
AVR_GCC="avr-gcc"
AVR_GPP="avr-g++"
AVR_OBJCOPY="avr-objcopy"
AVR_SIZE="avr-size"

# MCU 設定
MCU="attiny85"
F_CPU="16500000L"
ARDUINO_VER="10607"

# 編譯選項
CFLAGS="-c -g -Os -w -std=gnu11 -ffunction-sections -fdata-sections -MMD -flto -fno-fat-lto-objects"
CPPFLAGS="-c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -MMD -flto -fno-fat-lto-objects"
DEFINES="-DF_CPU=${F_CPU} -DARDUINO=${ARDUINO_VER} -DARDUINO_AVR_DIGISPARK -DARDUINO_ARCH_AVR -DUSB_VID=0x16C0 -DUSB_PID=0x27DB"
INCLUDES="-I${DIGISPARK_CORE} -I${DIGISPARK_VARIANT} -I${DIGISPARK_LIBS}/DigisparkKeyboard"

compile() {
    echo "════════════════════════════════════════════════════"
    echo "  編譯 Zip Bomb - macOS (DigiKeyboard)"
    echo "════════════════════════════════════════════════════"
    echo "檔案: ${SKETCH_NAME}.ino"
    echo "函式庫: DigiKeyboard (macOS 相容性更好)"
    echo "目標: ATtiny85 @ 16.5 MHz"
    echo ""

    mkdir -p "${BUILD_DIR}"

    # 複製並預處理
    echo "📝 準備原始碼..."
    cp "${SKETCH_PATH}" "${BUILD_DIR}/${SKETCH_NAME}.cpp"
    sed -i '1i #include <Arduino.h>' "${BUILD_DIR}/${SKETCH_NAME}.cpp"

    # 編譯核心
    echo "🔧 編譯 Arduino 核心..."
    for src in "${DIGISPARK_CORE}"/*.c; do
        if [ -f "$src" ]; then
            name=$(basename "$src" .c)
            ${AVR_GCC} ${CFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} "$src" -o "${BUILD_DIR}/${name}.o" 2>/dev/null
        fi
    done

    for src in "${DIGISPARK_CORE}"/*.cpp; do
        if [ -f "$src" ]; then
            name=$(basename "$src" .cpp)
            ${AVR_GPP} ${CPPFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} "$src" -o "${BUILD_DIR}/${name}.o" 2>/dev/null
        fi
    done

    # 編譯 DigiKeyboard 函式庫
    echo "⌨️  檢查 DigiKeyboard 函式庫..."
    # DigiKeyboard 是純標頭檔函式庫，不需要編譯 .cpp
    # 只需要編譯內部的 USB 驅動

    # 編譯 usbdrv.c
    if [ -f "${DIGISPARK_LIBS}/DigisparkKeyboard/usbdrv.c" ]; then
        ${AVR_GCC} ${CFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} \
            "${DIGISPARK_LIBS}/DigisparkKeyboard/usbdrv.c" -o "${BUILD_DIR}/usbdrv.o" 2>/dev/null
    fi

    # 編譯 oddebug.c (如果存在)
    if [ -f "${DIGISPARK_LIBS}/DigisparkKeyboard/oddebug.c" ]; then
        ${AVR_GCC} ${CFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} \
            "${DIGISPARK_LIBS}/DigisparkKeyboard/oddebug.c" -o "${BUILD_DIR}/oddebug.o" 2>/dev/null || true
    fi

    # 編譯 osccal.c (如果存在)
    if [ -f "${DIGISPARK_LIBS}/DigisparkKeyboard/osccal.c" ]; then
        ${AVR_GCC} ${CFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} \
            "${DIGISPARK_LIBS}/DigisparkKeyboard/osccal.c" -o "${BUILD_DIR}/osccal.o" 2>/dev/null || true
    fi

    # 編譯 usbdrvasm.S
    if [ -f "${DIGISPARK_LIBS}/DigisparkKeyboard/usbdrvasm.S" ]; then
        ${AVR_GCC} -x assembler-with-cpp ${DEFINES} -mmcu=${MCU} ${INCLUDES} -c \
            "${DIGISPARK_LIBS}/DigisparkKeyboard/usbdrvasm.S" -o "${BUILD_DIR}/usbdrvasm.o" 2>/dev/null || true
    fi

    # 編譯 sketch
    echo "💣 編譯 Zip Bomb 攻擊程式..."
    ${AVR_GPP} ${CPPFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} \
        "${BUILD_DIR}/${SKETCH_NAME}.cpp" -o "${BUILD_DIR}/${SKETCH_NAME}.o" 2>/dev/null

    # 連結
    echo "🔗 連結..."
    ${AVR_GCC} -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=${MCU} \
        ${BUILD_DIR}/*.o -o "${BUILD_DIR}/${SKETCH_NAME}.elf" 2>/dev/null

    # 生成 hex
    echo "📦 生成韌體..."
    ${AVR_OBJCOPY} -O ihex -R .eeprom "${BUILD_DIR}/${SKETCH_NAME}.elf" "${BUILD_DIR}/${SKETCH_NAME}.hex"

    # 顯示大小
    echo ""
    echo "════════════════════════════════════════════════════"
    echo "  程式大小統計"
    echo "════════════════════════════════════════════════════"
    ${AVR_SIZE} -C --mcu=${MCU} "${BUILD_DIR}/${SKETCH_NAME}.elf"

    echo ""
    echo "✅ 編譯成功!"
    echo "📍 韌體位置: ${BUILD_DIR}/${SKETCH_NAME}.hex"
    echo ""
}

upload() {
    HEX_FILE="${BUILD_DIR}/${SKETCH_NAME}.hex"

    if [ ! -f "$HEX_FILE" ]; then
        echo "❌ 錯誤: 找不到 ${HEX_FILE}"
        echo "請先執行: ./build_zipbomb_macos_digi.sh compile"
        exit 1
    fi

    echo "════════════════════════════════════════════════════"
    echo "  燒錄到 Digispark"
    echo "════════════════════════════════════════════════════"
    echo "目標: macOS Zip Bomb (DigiKeyboard 版本)"
    echo "函式庫: DigiKeyboard (macOS 相容性更好)"
    echo "韌體: ${HEX_FILE}"
    echo ""
    echo "⚠️  請在 60 秒內插入 Digispark 裝置"
    echo ""
    echo "步驟:"
    echo "  1. 如果 Digispark 已插入，請先拔除"
    echo "  2. 等待下方提示"
    echo "  3. 重新插入 Digispark"
    echo "  4. 等待燒錄完成"
    echo ""
    echo "────────────────────────────────────────────────────"
    echo ""

    micronucleus --run "${HEX_FILE}"

    if [ $? -eq 0 ]; then
        echo ""
        echo "════════════════════════════════════════════════════"
        echo "  ✅ 燒錄完成!"
        echo "════════════════════════════════════════════════════"
        echo "目標系統: macOS"
        echo "函式庫: DigiKeyboard (更好的 macOS 相容性)"
        echo "攻擊類型: Zip Bomb (完整遞迴解壓)"
        echo "預期大小: 68.7 GB"
        echo ""
        echo "📋 macOS 測試注意事項:"
        echo "  • 確認系統偏好設定 → 安全性 → 允許從任何來源安裝"
        echo "  • 確認沒有啟用「安全鍵盤輸入」"
        echo "  • 如果還是無法識別，請參考 README 的故障排除"
        echo ""
        echo "⚠️  重要提醒:"
        echo "  • 僅在虛擬機中測試"
        echo "  • 確保磁碟空間充足 (>70GB)"
        echo "  • 測試前建立 VM 快照"
        echo ""
    else
        echo ""
        echo "❌ 燒錄失敗"
        echo "請檢查:"
        echo "  • Digispark 是否正確插入"
        echo "  • USB 連接是否穩定"
        echo "  • udev 規則是否正確設定"
        echo ""
    fi
}

clean() {
    echo "🧹 清理建置目錄..."
    rm -rf "${BUILD_DIR}"
    echo "✅ 完成"
}

show_help() {
    echo "Zip Bomb macOS DigiKeyboard 版本編譯腳本"
    echo ""
    echo "用法: $0 [指令]"
    echo ""
    echo "指令:"
    echo "  compile    編譯 zipbomb_macos_digi.ino"
    echo "  upload     燒錄到 Digispark"
    echo "  all        編譯 + 燒錄"
    echo "  clean      清理建置檔案"
    echo "  help       顯示此說明"
    echo ""
    echo "範例:"
    echo "  $0 compile       # 只編譯"
    echo "  $0 upload        # 只燒錄"
    echo "  $0 all           # 編譯並燒錄"
    echo ""
    echo "DigiKeyboard vs TrinketHidCombo:"
    echo "  • DigiKeyboard: macOS 相容性更好（推薦）"
    echo "  • TrinketHidCombo: 功能更多但可能在 macOS 上無法識別"
    echo ""
}

# 主程式
case "${1:-compile}" in
    compile)
        compile
        ;;
    upload)
        upload
        ;;
    all)
        compile
        echo ""
        read -p "按 Enter 繼續燒錄，或 Ctrl+C 取消..."
        echo ""
        upload
        ;;
    clean)
        clean
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "❌ 未知的指令: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
