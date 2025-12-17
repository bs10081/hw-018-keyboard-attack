#!/bin/bash
# Zip Bomb macOS 版本專用編譯腳本
# 用於編譯和燒錄 zipbomb_macos.ino 到 Digispark

set -e

SKETCH_NAME="zipbomb_macos"
SKETCH_PATH="$(pwd)/${SKETCH_NAME}.ino"
BUILD_DIR="$(pwd)/build_zipbomb_macos"

# 檢查原始檔案是否存在
if [ ! -f "$SKETCH_PATH" ]; then
    echo "❌ 錯誤: 找不到 ${SKETCH_NAME}.ino"
    echo "請確認檔案位於: $SKETCH_PATH"
    exit 1
fi

# Digistump 和 TrinketHidCombo 路徑
DIGISTUMP_PATH="$HOME/.arduino15/packages/digistump/hardware/avr/1.6.7"
TRINKET_LIB="$HOME/Arduino/libraries/TrinketHidCombo"
DIGISPARK_CORE="${DIGISTUMP_PATH}/cores/tiny"
DIGISPARK_VARIANT="${DIGISTUMP_PATH}/variants/digispark"

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
DEFINES="-DF_CPU=${F_CPU} -DARDUINO=${ARDUINO_VER} -DARDUINO_AVR_DIGISPARK -DARDUINO_ARCH_AVR"
INCLUDES="-I${DIGISPARK_CORE} -I${DIGISPARK_VARIANT} -I${TRINKET_LIB} -I${TRINKET_LIB}/usbdrv"

compile() {
    echo "════════════════════════════════════════════════════"
    echo "  編譯 Zip Bomb - macOS 版本"
    echo "════════════════════════════════════════════════════"
    echo "檔案: ${SKETCH_NAME}.ino"
    echo "目標: ATtiny85 @ 16.5 MHz"
    echo ""

    # 建立建置目錄
    mkdir -p "${BUILD_DIR}"

    # 複製 .ino 為 .cpp
    echo "📝 準備原始碼..."
    cp "${SKETCH_PATH}" "${BUILD_DIR}/${SKETCH_NAME}.cpp"
    sed -i '1i #include <Arduino.h>' "${BUILD_DIR}/${SKETCH_NAME}.cpp"

    # 編譯核心檔案
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

    # 編譯 TrinketHidCombo 函式庫
    echo "🎮 編譯 TrinketHidCombo 函式庫..."
    ${AVR_GPP} ${CPPFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} \
        "${TRINKET_LIB}/TrinketHidCombo.cpp" -o "${BUILD_DIR}/TrinketHidCombo.o" 2>/dev/null

    ${AVR_GCC} ${CFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} \
        "${TRINKET_LIB}/TrinketHidComboC.c" -o "${BUILD_DIR}/TrinketHidComboC.o" 2>/dev/null

    ${AVR_GCC} ${CFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} \
        "${TRINKET_LIB}/usbdrv_includer.c" -o "${BUILD_DIR}/usbdrv_includer.o" 2>/dev/null

    ${AVR_GCC} -x assembler-with-cpp ${DEFINES} -mmcu=${MCU} ${INCLUDES} -c \
        "${TRINKET_LIB}/usbdrvasm_includer.S" -o "${BUILD_DIR}/usbdrvasm_includer.o" 2>/dev/null

    # 編譯 sketch
    echo "💣 編譯 Zip Bomb 攻擊程式..."
    ${AVR_GPP} ${CPPFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} \
        "${BUILD_DIR}/${SKETCH_NAME}.cpp" -o "${BUILD_DIR}/${SKETCH_NAME}.o" 2>/dev/null

    # 連結
    echo "🔗 連結..."
    ${AVR_GCC} -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=${MCU} \
        ${BUILD_DIR}/*.o -o "${BUILD_DIR}/${SKETCH_NAME}.elf" 2>/dev/null

    # 生成 hex 檔
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
        echo "請先執行: ./build_zipbomb_macos.sh compile"
        exit 1
    fi

    echo "════════════════════════════════════════════════════"
    echo "  燒錄到 Digispark"
    echo "════════════════════════════════════════════════════"
    echo "目標: macOS Zip Bomb 攻擊"
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
        echo "攻擊類型: Zip Bomb (42.zip 第一層)"
        echo "目標路徑: /tmp"
        echo "預期大小: 68.7 GB"
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
    echo "Zip Bomb macOS 版本編譯腳本"
    echo ""
    echo "用法: $0 [指令]"
    echo ""
    echo "指令:"
    echo "  compile    編譯 zipbomb_macos.ino"
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
