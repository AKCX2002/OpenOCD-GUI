#!/bin/bash

# 构建工具脚本：自动拉取和编译OpenOCD（重点）和sunxi-tools（可选）

set -e

# 工具目录
TOOLS_DIR="${PWD}/tools"
SUNXI_DIR="${TOOLS_DIR}/sunxi-tools"
OPENOCD_DIR="${TOOLS_DIR}/openocd"

# 是否构建sunxi-tools（默认：false，重点关注OpenOCD）
BUILD_SUNXI=${BUILD_SUNXI:-false}

# 创建工具目录
mkdir -p "${TOOLS_DIR}"

# 检测操作系统
OS="$(uname -s)"

# 安装依赖
echo "=== 安装依赖 ==="
if [ "${OS}" = "Linux" ]; then
    # Ubuntu/Debian
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y build-essential git autoconf automake libtool libusb-1.0-0-dev libftdi-dev libfdt-dev zlib1g-dev
        # 检查是否安装成功
        if [ ! -f "/usr/include/libfdt.h" ]; then
            echo "错误：libfdt-dev 安装失败"
            # 尝试从源代码安装libfdt
            echo "尝试从源代码安装libfdt"
            git clone https://github.com/devicetree-org/libfdt.git "${TOOLS_DIR}/libfdt"
            cd "${TOOLS_DIR}/libfdt"
            make
            sudo make install
            cd "${SUNXI_DIR}"
        fi
    # CentOS/RHEL
    elif command -v yum &> /dev/null; then
        sudo yum install -y gcc make git autoconf automake libtool libusb1-devel libftdi-devel libfdt-devel zlib-devel
    fi
elif [ "${OS}" = "Darwin" ]; then
    # macOS
    if command -v brew &> /dev/null; then
        brew install libusb libftdi libfdt zlib
    fi
elif [ "${OS}" = "MINGW64_NT-10.0" ] || [ "${OS}" = "CYGWIN_NT-10.0" ]; then
    # Windows (Git Bash)
    echo "请确保已安装必要的依赖：libusb, libftdi, libfdt, zlib"
fi

# 拉取和编译sunxi-tools（可选）
if [ "$BUILD_SUNXI" = "true" ]; then
    echo "=== 拉取和编译 sunxi-tools ==="
    if [ ! -d "${SUNXI_DIR}" ]; then
        git clone https://github.com/linux-sunxi/sunxi-tools.git "${SUNXI_DIR}"
    fi

    cd "${SUNXI_DIR}"
    git pull
    make clean

    # 检查是否存在libfdt.h
    if [ -f "/usr/include/libfdt.h" ] || [ -f "/usr/local/include/libfdt.h" ]; then
        # 有libfdt.h，正常编译
        make
    else
        # 没有libfdt.h，尝试只编译不依赖libfdt的工具
        echo "警告：未找到libfdt.h，尝试只编译不依赖libfdt的工具"
        # 只编译sunxi-fexc和sunxi-bootinfo
        make sunxi-fexc sunxi-bootinfo
    fi
fi

# 拉取和编译openocd
echo "=== 拉取和编译 openocd ==="
if [ ! -d "${OPENOCD_DIR}" ]; then
    git clone https://github.com/openocd-org/openocd.git "${OPENOCD_DIR}"
fi

cd "${OPENOCD_DIR}"
git pull

# 根据操作系统执行不同的构建命令
if [ "${OS}" = "Linux" ]; then
    ./bootstrap
    ./configure
    make clean
    make
elif [ "${OS}" = "Darwin" ]; then
    # macOS
    ./bootstrap
    ./configure
    make clean
    make
elif [ "${OS}" = "MINGW64_NT-10.0" ] || [ "${OS}" = "CYGWIN_NT-10.0" ]; then
    # Windows (Git Bash)
    ./bootstrap
    ./configure
    make clean
    make
else
    echo "不支持的操作系统：${OS}"
    exit 1
fi

# 复制可执行文件到bin目录
cd "${TOOLS_DIR}/.."
mkdir -p "${PWD}/bin"

# 根据操作系统复制不同的可执行文件
if [ "${OS}" = "Linux" ] || [ "${OS}" = "Darwin" ]; then
    # 复制OpenOCD
    if [ -f "${OPENOCD_DIR}/src/openocd" ]; then
        cp "${OPENOCD_DIR}/src/openocd" "${PWD}/bin/"
    fi
    # 复制sunxi-fel（如果BUILD_SUNXI为true）
    if [ "$BUILD_SUNXI" = "true" ] && [ -f "${SUNXI_DIR}/sunxi-fel" ]; then
        cp "${SUNXI_DIR}/sunxi-fel" "${PWD}/bin/"
    fi
elif [ "${OS}" = "MINGW64_NT-10.0" ] || [ "${OS}" = "CYGWIN_NT-10.0" ]; then
    # Windows
    # 复制OpenOCD
    cp "${OPENOCD_DIR}/src/openocd.exe" "${PWD}/bin/" 2>/dev/null || cp "${OPENOCD_DIR}/src/openocd" "${PWD}/bin/"
    # 复制sunxi-fel（如果BUILD_SUNXI为true）
    if [ "$BUILD_SUNXI" = "true" ]; then
        cp "${SUNXI_DIR}/sunxi-fel.exe" "${PWD}/bin/" 2>/dev/null || cp "${SUNXI_DIR}/sunxi-fel" "${PWD}/bin/"
    fi
fi

echo "=== 工具构建完成 ==="
echo "可执行文件已复制到 bin/ 目录"
