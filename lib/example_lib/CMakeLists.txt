file(GLOB EXAMPLE_LIB_SOURCES CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.c
)

add_library(example_lib STATIC
    ${EXAMPLE_LIB_SOURCES}
)

target_include_directories(example_lib PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)
