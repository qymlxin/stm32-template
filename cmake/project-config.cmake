# 项目名称
set(PROJECT_ID stm32_project)

# 最终固件文件名
set(FIRMWARE_TARGET firmware)

# 平台目录
set(STM32_PLATFORM stm32f1)

# CPU 内核
set(MCU_CPU cortex-m3)

# linker script
set(MCU_LINKER_SCRIPT stm32f103c8.ld)

# startup 文件
set(MCU_STARTUP_FILE startup_stm32f10x_md.s)
