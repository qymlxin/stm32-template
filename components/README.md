# `components/`

`components/` 用于存放面向当前项目功能的组件，例如通信协议、传感器驱动、状态机、数据编码和业务模块。

组件通常比 `lib/` 更接近具体产品功能，但仍然应该通过独立 target 管理自己的源文件、头文件和依赖。

## 推荐目录结构

```text
components/
└── protocol/
    ├── CMakeLists.txt
    ├── include/
    │   └── protocol.h
    └── src/
        └── protocol.c
```

`components/protocol/CMakeLists.txt`：

```cmake
add_library(protocol STATIC
    src/protocol.c
)

target_include_directories(protocol PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
```

如果组件使用 STM32 平台接口，可以声明平台依赖：

```cmake
target_link_libraries(protocol PUBLIC
    stm32_platform
)
```

## flat 结构

组件也可以不拆分 `src` 和 `include`：

```text
components/
└── protocol/
    ├── CMakeLists.txt
    ├── protocol.h
    └── protocol.c
```

```cmake
add_library(protocol STATIC
    protocol.c
)

target_include_directories(protocol PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)
```

## 显式加入根工程

在根目录 `CMakeLists.txt` 中加入组件目录，并确保它位于使用方之前：

```cmake
add_subdirectory(platform/${STM32_PLATFORM})
add_subdirectory(components/protocol)
add_subdirectory(bsp)
add_subdirectory(app)
```

如果应用层直接使用组件，在 `app/CMakeLists.txt` 中显式链接：

```cmake
target_link_libraries(app INTERFACE
    bsp
    stm32_platform
    protocol
)
```

如果只有 BSP 使用组件，则在 `bsp/CMakeLists.txt` 中链接：

```cmake
target_link_libraries(bsp INTERFACE
    stm32_platform
    protocol
)
```

依赖关系应尽量保持清晰：

```text
app -> protocol
bsp -> sensor
protocol -> ring_buffer
```

## 组件依赖其他库

```cmake
add_library(protocol STATIC
    src/protocol.c
)

target_include_directories(protocol PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(protocol PUBLIC
    ring_buffer
)
```

如果只是在编译组件时需要某个依赖，而使用组件的目标不需要继承它，可以使用 `PRIVATE`：

```cmake
target_link_libraries(protocol PRIVATE
    ring_buffer
)
```

## 编译选项和宏

组件专用配置不要随意写到根目录的全局编译选项中，可以写在自己的 target 上：

```cmake
target_compile_definitions(protocol PRIVATE
    PROTOCOL_ENABLE_CRC
)

target_compile_options(protocol PRIVATE
    -Wno-unused-parameter
)
```

## 约定

- 每个组件目录都包含自己的 `CMakeLists.txt`。
- target 名称建议与组件目录名一致。
- 组件只声明自己需要的依赖，不默认链接所有项目库。
- 组件的公共头文件目录使用 `PUBLIC` 或 `INTERFACE` 暴露。
- 组件内部实现文件使用 `PRIVATE` 逻辑，避免把不必要的目录暴露给整个工程。
