#!/usr/bin/env bash

set -e

COMMAND="$1"
BUILD_TYPE="${2:-debug}"

case "$BUILD_TYPE" in
    debug|release)
        ;;
    *)
        echo "Error: build type must be:"
        echo "  debug"
        echo "  release"
        exit 1
        ;;
esac

show_help()
{
    echo "STM32 project helper"
    echo
    echo "Usage:"
    echo "  ./scripts/stm32.sh <command> [debug|release]"
    echo
    echo "Commands:"
    echo "  configure   Configure CMake"
    echo "  build       Build firmware"
    echo "  rebuild     Delete build directory and rebuild"
    echo "  clean       Clean compiled files"
    echo "  flash       Build and flash firmware"
    echo "  size        Show firmware size"
    echo "  output      Show generated firmware files"
    echo "  help        Show this help"
    echo
    echo "Examples:"
    echo "  ./scripts/stm32.sh configure"
    echo "  ./scripts/stm32.sh build"
    echo "  ./scripts/stm32.sh build release"
    echo "  ./scripts/stm32.sh flash"
    echo "  ./scripts/stm32.sh flash release"
    echo "  ./scripts/stm32.sh clean"
    echo "  ./scripts/stm32.sh rebuild"
}

case "$COMMAND" in

    configure)
        echo "Configuring $BUILD_TYPE..."
        cmake --preset "$BUILD_TYPE"
        ;;

    build)
        echo "Building $BUILD_TYPE..."

        cmake --preset "$BUILD_TYPE"
        cmake --build --preset "$BUILD_TYPE"
        ;;

    rebuild)
        echo "Rebuilding $BUILD_TYPE..."

        rm -rf "build/$BUILD_TYPE"

        cmake --preset "$BUILD_TYPE"
        cmake --build --preset "$BUILD_TYPE"
        ;;

    clean)
        echo "Cleaning $BUILD_TYPE..."

        if [ -d "build/$BUILD_TYPE" ]; then
            cmake --build --preset "$BUILD_TYPE" --target clean
        else
            echo "Nothing to clean."
        fi
        ;;

    flash)
        echo "Building and flashing $BUILD_TYPE..."

        cmake --preset "$BUILD_TYPE"
        cmake --build --preset "$BUILD_TYPE" --target flash
        ;;

    size)
        ELF_FILE="build/$BUILD_TYPE/firmware.elf"

        if [ ! -f "$ELF_FILE" ]; then
            echo "Firmware not found:"
            echo "  $ELF_FILE"
            echo
            echo "Build first:"
            echo "  ./scripts/stm32.sh build $BUILD_TYPE"
            exit 1
        fi

        arm-none-eabi-size "$ELF_FILE"
        ;;

    output)
        OUTPUT_DIR="build/$BUILD_TYPE"

        echo "Firmware output:"
        echo

        for file in \
            "$OUTPUT_DIR/firmware.elf" \
            "$OUTPUT_DIR/firmware.hex" \
            "$OUTPUT_DIR/firmware.bin" \
            "$OUTPUT_DIR/firmware.map"
        do
            if [ -f "$file" ]; then
                echo "  $file"
            fi
        done
        ;;

    help|-h|--help|"")
        show_help
        ;;

    *)
        echo "Unknown command:"
        echo "  $COMMAND"
        echo
        show_help
        exit 1
        ;;
esac
