# STM32 CMake Template

用于 STM32 裸机开发的可复用 CMake 工程模板。

当前默认环境：

* MCU：STM32F103C8T6
* CPU：ARM Cortex-M3
* Library：STM32F10x SPL
* Compiler：ARM GNU Toolchain
* Build：CMake + Ninja
* Flash / Debug：OpenOCD + ST-Link
* Debugger：GDB + Cortex-Debug

工程本身不绑定具体 IDE，可用于 VS Code、Cursor 或其他支持 CMake / `compile_commands.json` 的开发环境。

## 目录结构

```text id="dm7wgq"
.
├── app/
│   ├── include/
│   ├── src/
│   └── CMakeLists.txt
├── bsp/
│   ├── include/
│   ├── src/
│   └── CMakeLists.txt
├── platform/
│   └── stm32f1/
│       ├── cmsis/
│       ├── spl/
│       ├── system/
│       ├── startup/
│       ├── linker/
│       ├── stm32f10x_conf.h
│       └── CMakeLists.txt
├── cmake/
│   ├── arm-none-eabi-gcc.cmake
│   └── project-config.cmake
├── debug/
│   └── openocd.cfg
├── ide-templates/
│   ├── shared/
│   ├── cpp-tools/
│   └── clangd/
├── scripts/
│   ├── init-project.sh
│   └── stm32.sh
├── CMakeLists.txt
├── CMakePresets.json
├── .gitignore
└── README.md
```

## 目录职责

* `app/`：应用逻辑、状态机、协议、业务代码。
* `bsp/`：LED、按键、串口、电机、传感器等板级代码。
* `platform/`：CMSIS、SPL、startup、system、linker script 等 MCU 平台代码。
* `cmake/`：工具链和项目统一配置。
* `debug/`：OpenOCD 等调试配置。
* `ide-templates/`：可选 IDE 配置模板。
* `scripts/`：项目初始化、编译、烧录等辅助命令。

## 环境要求

以下命令需要存在于系统 `PATH`：

```text id="xedajm"
arm-none-eabi-gcc
arm-none-eabi-g++
arm-none-eabi-objcopy
arm-none-eabi-size
arm-none-eabi-gdb
cmake
ninja
openocd
```

检查：

```bash id="p3bmf4"
arm-none-eabi-gcc --version
arm-none-eabi-gdb --version
cmake --version
ninja --version
openocd --version
```

模板不会写死 `/opt/homebrew/bin`、`/usr/bin`、Windows 盘符等系统路径。

## 项目配置

统一配置位于：

```text id="6r13xo"
cmake/project-config.cmake
```

示例：

```cmake id="kbuy9k"
set(PROJECT_ID stm32_project)
set(FIRMWARE_TARGET firmware)
set(STM32_PLATFORM stm32f1)
set(MCU_CPU cortex-m3)
set(MCU_LINKER_SCRIPT stm32f103c8.ld)
set(MCU_STARTUP_FILE startup_stm32f10x_md.s)
```

`PROJECT_ID` 是项目逻辑名称，例如：

```text id="17ecki"
motor_controller
smart_lock
uwb_node
```

建议保持：

```cmake id="dikif2"
set(FIRMWARE_TARGET firmware)
```

最终始终生成：

```text id="glos5l"
firmware.elf
firmware.hex
firmware.bin
firmware.map
```

这样修改项目名称后，IDE 仍然可以固定调试：

```text id="76dhoc"
build/debug/firmware.elf
```

## 初始化项目

第一次使用：

```bash id="3eokbl"
chmod +x scripts/init-project.sh scripts/stm32.sh
```

交互初始化：

```bash id="8dyqgj"
./scripts/init-project.sh
```

可选择：

```text id="oj6g0q"
1) Microsoft C/C++
2) clangd
3) None
```

也支持直接指定：

```bash id="xkc764"
./scripts/init-project.sh motor_controller cpp
./scripts/init-project.sh motor_controller clangd
./scripts/init-project.sh motor_controller none
```

初始化脚本会：

```text id="f1pg3p"
修改 PROJECT_ID
删除旧 build/
删除旧 .vscode/
清理本地 .clangd
复制选择的 IDE 配置
```

## IDE 模板

```text id="ezql9c"
ide-templates/
├── shared/
│   └── .vscode/
│       ├── tasks.json
│       └── launch.json
├── cpp-tools/
│   └── .vscode/
│       └── settings.json
└── clangd/
    └── .vscode/
        └── settings.json
```

`shared` 保存 Build、Flash、Debug 公共配置。

`cpp-tools` 保存 Microsoft C/C++ 插件配置。

`clangd` 保存 clangd 配置。

初始化后会复制到项目根目录：

```text id="mo2zmn"
.vscode/
```

## Git 忽略配置

推荐：

```gitignore id="wd51fp"
/.vscode/
/.idea/
/.cursor/
/.cache/
/.clangd-index/
```

前面的 `/` 表示只忽略仓库根目录，因此不会影响：

```text id="yvcj61"
ide-templates/shared/.vscode/
ide-templates/cpp-tools/.vscode/
ide-templates/clangd/.vscode/
```

## 常用命令

查看帮助：

```bash id="7i8483"
./scripts/stm32.sh help
```

### Debug

```bash id="ke2zm5"
./scripts/stm32.sh debug
```

等价于：

```bash id="6x1rcz"
./scripts/stm32.sh build debug
```

Debug 使用：

```text id="hd886y"
-Og
-g3
```

输出：

```text id="0r08xb"
build/debug/
```

### Release

```bash id="h3yjk7"
./scripts/stm32.sh release
```

等价于：

```bash id="prvg12"
./scripts/stm32.sh build release
```

Release 使用：

```text id="4e16ps"
-O2
```

输出：

```text id="c8zd60"
build/release/
```

### Configure

```bash id="9psboz"
./scripts/stm32.sh configure
./scripts/stm32.sh configure release
```

### Build

```bash id="ffjl6m"
./scripts/stm32.sh build
./scripts/stm32.sh build release
```

### Flash

```bash id="z05cw7"
./scripts/stm32.sh flash
./scripts/stm32.sh flash release
```

流程：

```text id="gj5a7x"
CMake
↓
Build
↓
firmware.elf
↓
OpenOCD
↓
ST-Link
↓
STM32
```

成功时一般会看到：

```text id="ljxpyp"
Programming Finished
Verified OK
Resetting Target
```

### Rebuild

```bash id="thmk27"
./scripts/stm32.sh rebuild
./scripts/stm32.sh rebuild release
```

会删除对应的 `build/debug/` 或 `build/release/` 后重新构建。

### Clean

```bash id="okh563"
./scripts/stm32.sh clean
./scripts/stm32.sh clean release
```

### Size

```bash id="umn6nb"
./scripts/stm32.sh size
./scripts/stm32.sh size release
```

### Output

```bash id="3ey0oz"
./scripts/stm32.sh output
./scripts/stm32.sh output release
```

可能显示：

```text id="6iskrj"
firmware.elf
firmware.hex
firmware.bin
firmware.map
compile_commands.json
```

## 原始 CMake 命令

Debug：

```bash id="p9wwcl"
cmake --preset debug
cmake --build --preset debug
```

Release：

```bash id="f2sazh"
cmake --preset release
cmake --build --preset release
```

Flash：

```bash id="141yo1"
cmake --build --preset debug --target flash
cmake --build --preset release --target flash
```

## compile_commands.json

CMake 会生成：

```text id="ksejpn"
build/debug/compile_commands.json
build/release/compile_commands.json
```

其中包含真实的：

```text id="41qlgj"
编译器
include 路径
预处理宏
CPU 参数
编译选项
```

Microsoft C/C++ 和 clangd 都可以读取它。

## Microsoft C/C++

初始化：

```bash id="46jqg6"
./scripts/init-project.sh motor_controller cpp
```

代码补全和跳转主要读取：

```text id="guet86"
build/debug/compile_commands.json
```

## clangd

初始化：

```bash id="fmxscb"
./scripts/init-project.sh motor_controller clangd
```

如果 clangd 无法找到 ARM GNU Toolchain 的系统头文件，可在本机 IDE 配置中增加：

```text id="kpxxn1"
--query-driver=<本机 arm-none-eabi 工具链路径>
```

机器相关路径不要提交进公共模板。

## OpenOCD

当前 `debug/openocd.cfg`：

```text id="h01b25"
source [find interface/stlink.cfg]
source [find target/stm32f1x.cfg]
```

测试：

```bash id="a7oo6s"
openocd -f debug/openocd.cfg
```

## 调试

默认调试：

```text id="7xyw3j"
build/debug/firmware.elf
```

调试链路：

```text id="busfzq"
IDE
↓
Cortex-Debug
↓
arm-none-eabi-gdb
↓
OpenOCD
↓
ST-Link
↓
STM32
```

支持断点、单步、变量、Watch、Call Stack 和 CPU Registers。

## 当前 MCU

```text id="1pukix"
STM32F103C8T6
ARM Cortex-M3
Medium Density
64 KB Flash
20 KB SRAM
```

使用：

```text id="4js3xo"
STM32F10X_MD
USE_STDPERIPH_DRIVER
startup_stm32f10x_md.s
stm32f103c8.ld
```

## 更换 MCU

至少重新检查：

```text id="9a5r73"
CPU 架构
-mcpu 参数
芯片宏
startup
linker script
Flash / RAM
CMSIS Device
外设库
OpenOCD target
```

## 推荐工作流程

初始化：

```bash id="5uwt8a"
./scripts/init-project.sh motor_controller cpp
```

开发：

```bash id="u20fwf"
./scripts/stm32.sh debug
```

烧录：

```bash id="90p5yj"
./scripts/stm32.sh flash
```

完整重编：

```bash id="ty84mj"
./scripts/stm32.sh rebuild
```

Release：

```bash id="8sxm64"
./scripts/stm32.sh release
```

日常基本记住这四个即可：

```bash id="oj8mob"
./scripts/stm32.sh debug
./scripts/stm32.sh flash
./scripts/stm32.sh rebuild
./scripts/stm32.sh release
```
