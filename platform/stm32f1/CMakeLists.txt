file(GLOB SPL_SOURCES CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/spl/src/*.c
)

add_library(stm32_platform STATIC
    ${SPL_SOURCES}
    ${CMAKE_CURRENT_SOURCE_DIR}/system/system_stm32f10x.c
)

target_include_directories(stm32_platform PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}

    ${CMAKE_CURRENT_SOURCE_DIR}/cmsis/CM3/CoreSupport

    ${CMAKE_CURRENT_SOURCE_DIR}/cmsis/CM3/DeviceSupport/ST/STM32F10x

    ${CMAKE_CURRENT_SOURCE_DIR}/spl/inc
)

target_compile_definitions(stm32_platform PUBLIC
    STM32F10X_MD
    USE_STDPERIPH_DRIVER
)