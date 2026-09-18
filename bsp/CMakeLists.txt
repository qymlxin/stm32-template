file(GLOB BSP_SOURCES CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c
)

add_library(bsp INTERFACE)

target_sources(bsp INTERFACE
    ${BSP_SOURCES}
)

target_include_directories(bsp INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(bsp INTERFACE
    stm32_platform
)