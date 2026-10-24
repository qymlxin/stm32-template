# 引入 lib/ 下的各个独立库
add_subdirectory(example_lib)

# lib 总入口：app 只需要链接 lib
add_library(lib INTERFACE)

target_link_libraries(lib INTERFACE
    example_lib
)
