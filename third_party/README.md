# `third_party/`

`third_party/` 用于存放外部获取的库，例如 FreeRTOS、协议栈、文件系统和厂商提供的中间件。

第三方库不会自动加入工程。建议保留第三方源码原有结构，并通过库目录中的 `CMakeLists.txt` 或一个适配层接入项目。

## 源码库：标准目录结构

```text
third_party/
└── foo/
    ├── CMakeLists.txt
    ├── include/
    │   └── foo.h
    └── src/
        └── foo.c
```

`third_party/foo/CMakeLists.txt`：

```cmake
add_library(foo STATIC
    src/foo.c
)

target_include_directories(foo PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
```

根目录 `CMakeLists.txt` 中显式加入：

```cmake
add_subdirectory(platform/${STM32_PLATFORM})
add_subdirectory(third_party/foo)
add_subdirectory(bsp)
add_subdirectory(app)
```

再在使用方链接：

```cmake
target_link_libraries(app INTERFACE
    bsp
    stm32_platform
    foo
)
```

## 源码库：保留原有目录结构

例如第三方库本身不是 `src/include` 结构：

```text
third_party/
└── freertos/
    ├── CMakeLists.txt
    ├── Source/
    │   ├── tasks.c
    │   ├── queue.c
    │   └── include/
    └── portable/
        └── GCC/ARM_CM3/
            └── port.c
```

可以在自己的 `CMakeLists.txt` 中明确选择要编译的文件：

```cmake
add_library(freertos STATIC
    Source/tasks.c
    Source/queue.c
    portable/GCC/ARM_CM3/port.c
)

target_include_directories(freertos PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/Source/include
    ${CMAKE_CURRENT_SOURCE_DIR}/portable/GCC/ARM_CM3
)

target_link_libraries(freertos PUBLIC
    stm32_platform
)
```

不要无条件递归编译整个 FreeRTOS 目录，因为其中可能包含多个不同芯片或编译器的移植层。

## 只有头文件的第三方库

```cmake
add_library(foo INTERFACE)

target_include_directories(foo INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
```

## 已经编译好的静态库

如果第三方库提供的是针对 ARM 裸机编译好的 `.a` 文件：

```text
third_party/
└── foo/
    ├── CMakeLists.txt
    ├── include/
    └── lib/
        └── libfoo.a
```

`CMakeLists.txt`：

```cmake
add_library(foo STATIC IMPORTED GLOBAL)

set_target_properties(foo PROPERTIES
    IMPORTED_LOCATION
        ${CMAKE_CURRENT_SOURCE_DIR}/lib/libfoo.a
    INTERFACE_INCLUDE_DIRECTORIES
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)
```

然后照常在根工程中调用：

```cmake
add_subdirectory(third_party/foo)
```

这个 `.a` 文件必须使用兼容的 `arm-none-eabi-gcc`、Cortex-M3 和 Thumb 配置编译，不能直接使用 macOS 或 Linux 主机上的库文件。

## 修改第三方代码的建议

- 优先保留原始源码不变。
- 项目专用配置放在适配层或项目自己的配置目录中。
- 如果必须修改第三方源码，应在提交说明中记录修改原因。
- 对于没有 CMake 支持的库，在其目录中补充一个只负责构建的 `CMakeLists.txt`。
