# F1C 通用下载平台

## 项目概述

通用下载平台是一个跨平台的固件下载工具，重点支持通过 OpenOCD 对各种 32 位 MCU 进行固件烧录和调试。

### 支持的平台
- Linux
- Windows
- macOS

### 支持的设备
- STM32 系列
- AT32 系列
- GD32 系列
- 其他支持 OpenOCD 的 MCU

## 核心功能

- **设备管理**：支持多种设备类型的检测和管理
- **固件管理**：支持 .bin、.hex、.elf 等多种固件格式
- **烧录工具**：集成 OpenOCD 烧录工具
- **操作功能**：设备检测、固件烧录、全片擦除、复位等
- **用户界面**：边栏式布局，提供直观的操作界面
- **日志系统**：实时显示操作日志和进度

## 技术架构

### 前端
- Flutter 框架，跨平台 UI
- Dart 语言，处理核心逻辑

### 后端
- 集成 OpenOCD 工具
- 自动工具拉取和编译
- 可扩展的设备驱动系统

## 安装和使用

### 前置依赖

#### Linux
```bash
sudo apt install build-essential git autoconf automake libtool libusb-1.0-0-dev libftdi-dev
```

#### Windows
- 安装 Git Bash
- 安装 MinGW 或 MSYS2

#### macOS
```bash
brew install git make gcc libusb
```

### 构建工具

项目包含自动构建脚本，可自动拉取和编译 OpenOCD：

```bash
./build_tools.sh
```

### 运行应用

```bash
flutter run -d linux  # Linux
flutter run -d windows  # Windows
flutter run -d macos  # macOS
```

## 项目结构

```
f1c/
├── lib/
│   ├── app.dart                # 应用入口
│   ├── main.dart              # 主入口
│   ├── pages/
│   │   ├── home_page.dart     # 主页面
│   │   └── settings_page.dart # 设置页面
│   ├── services/
│   │   ├── firmware_service.dart  # 固件服务
│   │   ├── device_service.dart    # 设备服务
│   │   └── tool_service.dart      # 工具服务
│   ├── models/
│   │   ├── device.dart       # 设备模型
│   │   └── firmware.dart     # 固件模型
│   └── widgets/
│       ├── sidebar.dart       # 侧边栏
│       ├── file_selector.dart # 文件选择器
│       └── log_viewer.dart    # 日志查看器
├── tools/
│   ├── build_tools.sh         # 工具构建脚本
│   └── README.md              # 工具说明
├── .github/
│   └── workflows/
│       └── build-tools.yml    # GitHub Actions配置
└── pubspec.yaml               # 项目配置
```

## 核心功能使用

### 1. 设备选择

在侧边栏中选择设备类型（STM32、AT32、GD32 等）。

### 2. 固件选择

点击 "浏览..." 按钮选择固件文件，支持 .bin、.hex、.elf 等格式。

### 3. 烧录设置

- **地址**：设置烧录地址（对于 .hex 和 .elf 文件可自动识别）
- **验证**：选择是否验证烧录结果
- **复位**：选择烧录后是否复位设备

### 4. 执行操作

- **开始下载**：执行固件烧录
- **执行功能**：执行其他操作，如设备检测、全片擦除、复位等

## 工具自动构建

项目使用 GitHub Actions 自动构建各平台的 OpenOCD 工具：

- **Linux**：在 Ubuntu 环境中构建
- **Windows**：在 Windows 环境中构建
- **macOS**：在 macOS 环境中构建

构建结果会作为 artifacts 上传，可在 GitHub Actions 页面下载。

## 故障排除

### 1. 工具未找到

如果应用提示找不到 OpenOCD 工具，请运行构建脚本：

```bash
./build_tools.sh
```

### 2. 设备未检测到

- 确保设备已正确连接
- 确保驱动程序已安装
- 尝试不同的 USB 端口

### 3. 烧录失败

- 检查固件文件是否正确
- 检查烧录地址是否正确
- 检查设备是否处于可烧录状态

## 贡献

欢迎贡献代码和提出建议！请提交 Pull Request 或 Issue。

## 许可证

本项目采用 MIT 许可证。
