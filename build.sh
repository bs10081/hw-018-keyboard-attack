#!/bin/bash
# Digispark HW-018 編譯與燒錄腳本
# 用法: ./build.sh [compile|upload|clean]

set -e

SKETCH_NAME="${SKETCH_NAME:-reverse_shell_optimized}"
SKETCH_PATH="$(pwd)/${SKETCH_NAME}.ino"
BUILD_DIR="$(pwd)/build"

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

# MCU 設定 (ATtiny85)
MCU="attiny85"
F_CPU="16500000L"
ARDUINO_VER="10607"

# 編譯選項
CFLAGS="-c -g -Os -w -std=gnu11 -ffunction-sections -fdata-sections -MMD -flto -fno-fat-lto-objects"
CPPFLAGS="-c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -MMD -flto -fno-fat-lto-objects"
DEFINES="-DF_CPU=${F_CPU} -DARDUINO=${ARDUINO_VER} -DARDUINO_AVR_DIGISPARK -DARDUINO_ARCH_AVR -DUSB_VID=0x16C0 -DUSB_PID=0x27DB"
INCLUDES="-I${DIGISPARK_CORE} -I${DIGISPARK_VARIANT} -I${DIGISPARK_LIBS}/DigisparkKeyboard"

compile() {
    echo "=== 編譯 ${SKETCH_NAME} ==="

    mkdir -p "${BUILD_DIR}"

    # 複製 .ino 為 .cpp
    cp "${SKETCH_PATH}" "${BUILD_DIR}/${SKETCH_NAME}.cpp"

    # 在 .cpp 開頭加入 Arduino.h
    sed -i '1i #include <Arduino.h>' "${BUILD_DIR}/${SKETCH_NAME}.cpp"

    # 編譯核心檔案
    echo "編譯核心..."
    for src in "${DIGISPARK_CORE}"/*.c; do
        if [ -f "$src" ]; then
            name=$(basename "$src" .c)
            ${AVR_GCC} ${CFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} "$src" -o "${BUILD_DIR}/${name}.o"
        fi
    done

    for src in "${DIGISPARK_CORE}"/*.cpp; do
        if [ -f "$src" ]; then
            name=$(basename "$src" .cpp)
            ${AVR_GPP} ${CPPFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} "$src" -o "${BUILD_DIR}/${name}.o"
        fi
    done

    # 編譯 DigiKeyboard 函式庫
    echo "編譯 DigiKeyboard..."
    for src in "${DIGISPARK_LIBS}/DigisparkKeyboard"/*.cpp; do
        if [ -f "$src" ]; then
            name=$(basename "$src" .cpp)
            ${AVR_GPP} ${CPPFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} "$src" -o "${BUILD_DIR}/${name}.o"
        fi
    done

    # 編譯 USB driver
    echo "編譯 USB driver..."
    ${AVR_GCC} ${CFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} \
        "${DIGISPARK_LIBS}/DigisparkKeyboard/usbdrv.c" -o "${BUILD_DIR}/usbdrv.o"

    ${AVR_GCC} ${CFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} \
        "${DIGISPARK_LIBS}/DigisparkKeyboard/osccal.c" -o "${BUILD_DIR}/osccal.o"

    ${AVR_GCC} ${CFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} \
        "${DIGISPARK_LIBS}/DigisparkKeyboard/oddebug.c" -o "${BUILD_DIR}/oddebug.o"

    ${AVR_GCC} -x assembler-with-cpp ${DEFINES} -mmcu=${MCU} ${INCLUDES} -c \
        "${DIGISPARK_LIBS}/DigisparkKeyboard/usbdrvasm.S" -o "${BUILD_DIR}/usbdrvasm.o"

    # 編譯 sketch
    echo "編譯 sketch..."
    ${AVR_GPP} ${CPPFLAGS} ${DEFINES} -mmcu=${MCU} ${INCLUDES} "${BUILD_DIR}/${SKETCH_NAME}.cpp" -o "${BUILD_DIR}/${SKETCH_NAME}.o"

    # 連結
    echo "連結..."
    ${AVR_GCC} -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=${MCU} \
        ${BUILD_DIR}/*.o -o "${BUILD_DIR}/${SKETCH_NAME}.elf"

    # 生成 hex 檔
    echo "生成 hex..."
    ${AVR_OBJCOPY} -O ihex -R .eeprom "${BUILD_DIR}/${SKETCH_NAME}.elf" "${BUILD_DIR}/${SKETCH_NAME}.hex"

    # 顯示大小
    echo ""
    echo "=== 程式大小 ==="
    ${AVR_SIZE} -C --mcu=${MCU} "${BUILD_DIR}/${SKETCH_NAME}.elf"

    echo ""
    echo "編譯完成: ${BUILD_DIR}/${SKETCH_NAME}.hex"
}

upload() {
    HEX_FILE="${BUILD_DIR}/${SKETCH_NAME}.hex"

    if [ ! -f "$HEX_FILE" ]; then
        echo "錯誤: 找不到 ${HEX_FILE}"
        echo "請先執行: ./build.sh compile"
        exit 1
    fi

    echo "=== 燒錄到 Digispark ==="
    echo ""
    echo ">>> 請在 60 秒內插入 Digispark 裝置 <<<"
    echo ""

    micronucleus --run "${HEX_FILE}"
}

clean() {
    echo "清理建置目錄..."
    rm -rf "${BUILD_DIR}"
    echo "完成"
}

case "${1:-compile}" in
    compile)
        compile
        ;;
    upload)
        upload
        ;;
    clean)
        clean
        ;;
    all)
        compile
        upload
        ;;
    *)
        echo "用法: $0 [compile|upload|clean|all]"
        exit 1
        ;;
esac
