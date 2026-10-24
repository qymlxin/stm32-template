# `lib/`

`lib/` 用于存放项目自己编写的、可以被多个模块复用的通用库，例如环形缓冲区、日志、数据结构和算法。

这里的库不会自动加入工程。新增库后，需要在项目根目录的 `CMakeLists.txt` 中显式声明，并在使用方显式链接。

## 推荐目录结构

### `src/include` 结构

```text
lib/
└── ring_buffer/
    ├── CMakeLists.txt
    ├── include/
    │   └── ring_buffer.h
    └── src/
        └── ring_buffer.c
```

`lib/ring_buffer/CMakeLists.txt`：

```cmake
add_library(ring_buffer STATIC
    src/ring_buffer.c
)

target_include_directories(ring_buffer PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
```

### flat 结构

头文件和源文件也可以直接放在库目录中：

```text
lib/
└── ring_buffer/
    ├── CMakeLists.txt
    ├── ring_buffer.h
    └── ring_buffer.c
```

对应的 `CMakeLists.txt`：

```cmake
add_library(ring_buffer STATIC
    ring_buffer.c
)

target_include_directories(ring_buffer PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)
```

## 在根工程中显式引入

根目录 `CMakeLists.txt` 中，应在 `app` 之前加入库目录：

```cmake
add_subdirectory(platform/${STM32_PLATFORM})
add_subdirectory(lib/ring_buffer)
add_subdirectory(bsp)
add_subdirectory(app)
```

然后让应用链接这个库。可以在 `app/CMakeLists.txt` 中添加：

```cmake
target_link_libraries(app INTERFACE
    bsp
    stm32_platform
    ring_buffer
)
```

应用代码中即可使用：

```c
#include "ring_buffer.h"
```

## 只有头文件的库

```text
lib/
└── constants/
    ├── CMakeLists.txt
    └── constants.h
```

```cmake
add_library(constants INTERFACE)

target_include_directories(constants INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}
)
```

## 库依赖其他库

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

`PUBLIC` 表示 `protocol` 自己需要 `ring_buffer`，同时使用 `protocol` 的目标也会继承这个依赖。

## 约定

- 每个库使用独立的 target 名称。
- target 名称应与库名一致，例如目录 `ring_buffer` 对应 target `ring_buffer`。
- 库自己的头文件目录、源文件和依赖写在库自己的 `CMakeLists.txt` 中。
- 只在实际使用库的目标上调用 `target_link_libraries()`。
