# 引入 components/ 下的各个组件
add_subdirectory(example_component)

# components 总入口
add_library(components INTERFACE)

target_link_libraries(components INTERFACE
    example_component
)
