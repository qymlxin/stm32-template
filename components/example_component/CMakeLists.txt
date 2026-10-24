file(GLOB EXAMPLE_COMPONENT_SOURCES CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.c
)

add_library(example_component STATIC
    ${EXAMPLE_COMPONENT_SOURCES}
)

target_include_directories(example_component PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(example_component PUBLIC
    lib
)
