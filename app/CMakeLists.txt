file(GLOB APP_SOURCES CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c
)

# main.c 由最终 firmware target 直接编译
list(REMOVE_ITEM APP_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main.c
)

add_library(app INTERFACE)

target_sources(app INTERFACE
    ${APP_SOURCES}
)

target_include_directories(app INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(app INTERFACE
    bsp
    stm32_platform
)