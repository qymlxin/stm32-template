# 引入 third_party/ 下的各个第三方库
add_subdirectory(example_third_party)

# third_party 总入口
add_library(third_party INTERFACE)

target_link_libraries(third_party INTERFACE
    example_third_party
)
