file(GLOB EXAMPLE_THIRD_PARTY_SOURCES CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.c
)

add_library(example_third_party STATIC
    ${EXAMPLE_THIRD_PARTY_SOURCES}
)

target_include_directories(example_third_party PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)
