cmake_minimum_required(VERSION 3.20)

# 统一项目配置
include(${CMAKE_SOURCE_DIR}/cmake/project-config.cmake)

project(${PROJECT_ID} C ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# 给 IDE / clangd / C/C++ 插件使用
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# MCU 编译参数
set(MCU_FLAGS
    -mcpu=${MCU_CPU}
    -mthumb
)

add_compile_options(
    ${MCU_FLAGS}

    -Wall
    -Wextra

    -ffunction-sections
    -fdata-sections

    $<$<CONFIG:Debug>:-Og>
    $<$<CONFIG:Debug>:-g3>

    $<$<CONFIG:Release>:-O2>
)

# 子模块
add_subdirectory(platform/${STM32_PLATFORM})
add_subdirectory(bsp)
add_subdirectory(app)

# 最终固件
add_executable(${FIRMWARE_TARGET}.elf

    app/src/main.c

    platform/${STM32_PLATFORM}/startup/${MCU_STARTUP_FILE}
)

target_link_libraries(${FIRMWARE_TARGET}.elf PRIVATE
    app
    bsp
    stm32_platform
)

target_link_options(${FIRMWARE_TARGET}.elf PRIVATE

    ${MCU_FLAGS}

    -T${CMAKE_SOURCE_DIR}/platform/${STM32_PLATFORM}/linker/${MCU_LINKER_SCRIPT}

    -Wl,--gc-sections

    -Wl,-Map=${FIRMWARE_TARGET}.map
)

# 生成 hex / bin，并显示固件大小
add_custom_command(
    TARGET ${FIRMWARE_TARGET}.elf
    POST_BUILD

    COMMAND ${CMAKE_OBJCOPY}
        -O ihex
        $<TARGET_FILE:${FIRMWARE_TARGET}.elf>
        ${CMAKE_CURRENT_BINARY_DIR}/${FIRMWARE_TARGET}.hex

    COMMAND ${CMAKE_OBJCOPY}
        -O binary
        $<TARGET_FILE:${FIRMWARE_TARGET}.elf>
        ${CMAKE_CURRENT_BINARY_DIR}/${FIRMWARE_TARGET}.bin

    COMMAND ${CMAKE_SIZE}
        $<TARGET_FILE:${FIRMWARE_TARGET}.elf>

    VERBATIM
)

# 查找 OpenOCD
find_program(OPENOCD_EXECUTABLE openocd)

# 一键烧录
if(OPENOCD_EXECUTABLE)

    add_custom_target(flash

        COMMAND ${OPENOCD_EXECUTABLE}
            -f ${CMAKE_SOURCE_DIR}/debug/openocd.cfg
            -c "program $<TARGET_FILE:${FIRMWARE_TARGET}.elf> verify reset exit"

        DEPENDS ${FIRMWARE_TARGET}.elf

        COMMENT "Flashing ${FIRMWARE_TARGET}.elf via OpenOCD"

        VERBATIM
    )

else()

    message(STATUS "OpenOCD not found in PATH; flash target will not be created.")

endif()