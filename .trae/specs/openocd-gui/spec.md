# OPENOCD-GUI - Product Requirement Document

## Overview
- **Summary**: OPENOCD-GUI是一个跨平台的固件下载工具，重点支持通过OpenOCD对各种32位MCU进行固件烧录和调试。
- **Purpose**: 为嵌入式开发人员提供一个直观、高效的图形界面工具，简化固件烧录和设备调试过程。
- **Target Users**: 嵌入式开发工程师、硬件工程师、学生和爱好者。

## Goals
- 提供跨平台的图形界面，支持Linux、Windows和macOS
- 集成OpenOCD工具，支持自动拉取和编译
- 支持多种32位MCU，包括STM32、AT32、GD32等
- 提供直观的边栏式布局，方便用户快速选择下载器、板子类型和固件文件
- 支持多种固件格式，包括.bin、.hex、.elf等
- 提供实时日志显示和操作进度条

## Non-Goals (Out of Scope)
- 不支持其他下载器类型，仅专注于OpenOCD
- 不支持8位或16位MCU
- 不提供高级调试功能，仅专注于固件烧录和基本设备操作
- 不集成IDE功能，仅作为独立工具使用

## Background & Context
- OpenOCD是一个开源的片上调试器和编程器，支持多种ARM和RISC-V设备
- 传统的OpenOCD使用命令行操作，对新手不友好
- 市场上缺乏跨平台的OpenOCD图形界面工具
- 嵌入式开发中固件烧录是一个常见且重要的操作

## Functional Requirements
- **FR-1**: 支持跨平台运行（Linux、Windows、macOS）
- **FR-2**: 集成OpenOCD工具，支持自动拉取和编译，且分平台各自编译
- **FR-3**: 支持多种32位MCU，包括STM32、AT32、GD32等
- **FR-4**: 提供边栏式布局，包含下载器选择、板子类型选择和固件目录配置
- **FR-5**: 支持多种固件格式，包括.bin、.hex、.elf等
- **FR-6**: 支持多固件文件同时烧录
- **FR-7**: 提供设备检测、固件烧录、全片擦除、复位等操作
- **FR-8**: 提供实时日志显示和操作进度条
- **FR-9**: 支持手动指定OpenOCD可执行文件路径

## Non-Functional Requirements
- **NFR-1**: 界面响应迅速，操作流畅
- **NFR-2**: 支持中文和英文界面
- **NFR-3**: 错误处理机制完善，提供清晰的错误提示
- **NFR-4**: 工具自动构建稳定可靠
- **NFR-5**: 代码结构清晰，易于维护和扩展

## Constraints
- **Technical**: 使用Flutter框架开发，支持Dart语言
- **Business**: 开源项目，零成本开发
- **Dependencies**: 依赖OpenOCD工具，需要网络连接拉取代码

## Assumptions
- 用户具有基本的嵌入式开发知识
- 用户的系统环境满足Flutter运行要求
- 用户能够连接到互联网以拉取OpenOCD代码

## Acceptance Criteria

### AC-1: 跨平台运行
- **Given**: 用户在Linux、Windows或macOS系统上
- **When**: 用户启动OPENOCD-GUI应用
- **Then**: 应用能够正常运行，界面显示正确
- **Verification**: `human-judgment`

### AC-2: OpenOCD工具集成
- **Given**: 用户运行build_tools.sh脚本
- **When**: 脚本执行完成
- **Then**: OpenOCD工具被成功拉取和编译，可执行文件位于bin目录
- **Verification**: `programmatic`

### AC-3: 设备支持
- **Given**: 用户选择支持的板子类型（如STM32F103C8T6）
- **When**: 用户执行设备检测操作
- **Then**: 应用能够正确检测到设备并显示相关信息
- **Verification**: `programmatic`

### AC-4: 固件烧录
- **Given**: 用户选择固件文件和烧录地址
- **When**: 用户点击"开始下载"按钮
- **Then**: 固件被成功烧录到设备，显示烧录进度和结果
- **Verification**: `programmatic`

### AC-5: 边栏式布局
- **Given**: 用户打开OPENOCD-GUI应用
- **When**: 用户查看界面布局
- **Then**: 应用显示左侧边栏（包含下载器、板子选择等）和右侧主内容区（包含固件配置、操作按钮等）
- **Verification**: `human-judgment`

### AC-6: 实时日志和进度
- **Given**: 用户执行烧录或其他操作
- **When**: 操作执行过程中
- **Then**: 应用显示实时操作日志和进度条
- **Verification**: `human-judgment`

## Open Questions
- [ ] 是否需要支持其他下载器类型？
- [ ] 是否需要添加高级调试功能？
- [ ] 是否需要支持更多的板子类型？
- [ ] 是否需要添加固件验证和校验功能？
