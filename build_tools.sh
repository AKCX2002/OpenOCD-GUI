#!/bin/bash
##############################################################################
# OpenOCD 自动化构建脚本
# 功能：从 OpenOCD 官方仓库克隆最新代码并编译，生成跨平台的可执行文件
# 支持平台：Linux、macOS、Windows
# 作者：OpenOCD-GUI 项目团队
# 版本：2.0
##############################################################################

set -e  # 遇到错误立即退出
set -o pipefail  # 管道命令中任意命令失败则整个管道失败

##############################################################################
# 全局变量定义
##############################################################################

# 项目目录结构
TOOLS_DIR="${PWD}/tools"           # 工具源代码目录
OPENOCD_DIR="${TOOLS_DIR}/openocd" # OpenOCD 源代码目录
BUILD_DIR="${PWD}/build"            # 编译输出目录
OUTPUT_DIR="${PWD}/output"          # 最终打包输出目录

# 构建版本号（默认使用日期格式）
BUILD_VERSION=${BUILD_VERSION:-$(date +%Y%m%d)}

##############################################################################
# 平台检测与标准化
##############################################################################

# 检测操作系统类型
OS="$(uname -s)"
# 检测硬件架构
ARCH="$(uname -m)"

# 标准化平台名称
case "${OS}" in
    Linux*)
        PLATFORM="linux"
        ;;
    Darwin*)
        PLATFORM="macos"
        ;;
    MINGW*|CYGWIN*|MSYS*)
        PLATFORM="windows"
        ;;
    *)
        echo "错误：不支持的操作系统类型 - ${OS}"
        exit 1
        ;;
esac

# 标准化架构名称
case "${ARCH}" in
    x86_64|amd64)
        ARCH_NAME="x86_64"
        ;;
    arm64|aarch64)
        ARCH_NAME="arm64"
        ;;
    *)
        ARCH_NAME="${ARCH}"
        ;;
esac

# 构建产物名称格式：openocd-{平台}-{架构}-{版本号}
PACKAGE_NAME="openocd-${PLATFORM}-${ARCH_NAME}-${BUILD_VERSION}"
PACKAGE_PATH="${OUTPUT_DIR}/${PACKAGE_NAME}"

##############################################################################
# 函数：打印构建配置信息
##############################################################################

print_build_config() {
    echo "========================================="
    echo "  OpenOCD 自动化构建配置"
    echo "========================================="
    echo "  操作系统: ${OS} (${PLATFORM})"
    echo "  硬件架构: ${ARCH} (${ARCH_NAME})"
    echo "  构建版本: ${BUILD_VERSION}"
    echo "  包名称: ${PACKAGE_NAME}"
    echo "  源代码目录: ${OPENOCD_DIR}"
    echo "  编译目录: ${BUILD_DIR}"
    echo "  输出目录: ${OUTPUT_DIR}"
    echo "========================================="
    echo ""
}

##############################################################################
# 函数：创建必要的目录结构
##############################################################################

create_directories() {
    echo "=== 创建目录结构 ==="
    mkdir -p "${TOOLS_DIR}"
    mkdir -p "${BUILD_DIR}"
    mkdir -p "${OUTPUT_DIR}"
    echo "✓ 目录结构创建完成"
    echo ""
}

##############################################################################
# 函数：检查构建环境
##############################################################################

check_build_environment() {
    echo "=== 检查构建环境 ==="
    
    local missing_tools=()
    local required_tools=("git" "make" "gcc" "autoconf" "automake" "libtool")
    
    # 检查必要的构建工具是否存在
    for tool in "${required_tools[@]}"; do
        if ! command -v "${tool}" &> /dev/null; then
            missing_tools+=("${tool}")
        else
            echo "✓ 找到 ${tool}"
        fi
    done
    
    # 如果有缺失的工具，打印错误并退出
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo ""
        echo "错误：缺少以下必要的构建工具："
        for tool in "${missing_tools[@]}"; do
            echo "  - ${tool}"
        done
        echo ""
        echo "请先安装这些工具后再运行构建脚本"
        exit 1
    fi
    
    echo "✓ 构建环境检查通过"
    echo ""
}

##############################################################################
# 函数：安装平台相关的依赖库
##############################################################################

install_platform_dependencies() {
    echo "=== 安装平台依赖库 ==="
    
    case "${PLATFORM}" in
        linux)
            install_linux_dependencies
            ;;
        macos)
            install_macos_dependencies
            ;;
        windows)
            install_windows_dependencies
            ;;
    esac
    
    echo "✓ 依赖库安装完成"
    echo ""
}

##############################################################################
# 函数：安装 Linux 平台依赖
##############################################################################

install_linux_dependencies() {
    if command -v apt-get &> /dev/null; then
        echo "检测到 Debian/Ubuntu 系统，使用 apt-get 安装依赖"
        sudo apt-get update
        sudo apt-get install -y \
            build-essential \
            git \
            autoconf \
            automake \
            libtool \
            libusb-1.0-0-dev \
            libftdi-dev \
            libfdt-dev \
            zlib1g-dev \
            pkg-config \
            zip
    elif command -v yum &> /dev/null; then
        echo "检测到 CentOS/RHEL 系统，使用 yum 安装依赖"
        sudo yum install -y \
            gcc \
            make \
            git \
            autoconf \
            automake \
            libtool \
            libusb1-devel \
            libftdi-devel \
            libfdt-devel \
            zlib-devel \
            pkgconfig
    else
        echo "警告：无法识别的 Linux 发行版，请手动安装依赖库"
    fi
}

##############################################################################
# 函数：安装 macOS 平台依赖
##############################################################################

install_macos_dependencies() {
    if command -v brew &> /dev/null; then
        echo "检测到 Homebrew，使用 brew 安装依赖"
        brew install \
            autoconf \
            automake \
            libtool \
            libusb \
            libftdi \
            pkg-config
    else
        echo "警告：未找到 Homebrew，请手动安装依赖库或先安装 Homebrew"
        echo "Homebrew 安装地址：https://brew.sh/"
    fi
}

##############################################################################
# 函数：安装 Windows 平台依赖
##############################################################################

install_windows_dependencies() {
    if command -v pacman &> /dev/null; then
        echo "检测到 MSYS2，使用 pacman 安装依赖"
        pacman -S --noconfirm \
            mingw-w64-x86_64-toolchain \
            mingw-w64-x86_64-libusb \
            mingw-w64-x86_64-libftdi \
            mingw-w64-x86_64-pkg-config
    else
        echo "警告：请确保已在 Windows 上安装 MSYS2 或 MinGW 及必要的依赖库"
    fi
}

##############################################################################
# 函数：获取 OpenOCD 源代码
##############################################################################

fetch_openocd_source() {
    echo "=== 获取 OpenOCD 源代码 ==="
    
    if [ ! -d "${OPENOCD_DIR}" ]; then
        echo "克隆 OpenOCD 仓库..."
        git clone https://github.com/openocd-org/openocd.git "${OPENOCD_DIR}"
    else
        echo "OpenOCD 仓库已存在，更新到最新版本..."
    fi
    
    cd "${OPENOCD_DIR}"
    
    # 确保在 master 分支并拉取最新代码
    git checkout master
    git pull origin master
    
    # 获取当前 commit 信息
    local git_short_hash=$(git rev-parse --short HEAD)
    local git_commit_date=$(git log -1 --format=%cd --date=short)
    local git_commit_message=$(git log -1 --format=%s)
    
    echo "✓ 当前代码版本: ${git_short_hash}"
    echo "✓ 提交日期: ${git_commit_date}"
    echo "✓ 提交信息: ${git_commit_message}"
    
    cd "${PWD}"
    echo ""
}

##############################################################################
# 函数：编译 OpenOCD
##############################################################################

build_openocd() {
    echo "=== 编译 OpenOCD ==="
    
    cd "${OPENOCD_DIR}"
    
    # 生成配置脚本
    echo "运行 bootstrap..."
    ./bootstrap
    
    # 配置编译选项
    echo "配置编译选项..."
    ./configure \
        --prefix="${BUILD_DIR}" \
        --disable-werror \
        --enable-dummy \
        --enable-usb-blaster \
        --enable-ftdi
    
    # 编译
    echo "开始编译 (使用 $(nproc) 个线程)..."
    make clean
    make -j$(nproc)
    
    # 安装到 BUILD_DIR
    echo "安装编译产物..."
    make install
    
    cd "${PWD}"
    echo "✓ OpenOCD 编译完成"
    echo ""
}

##############################################################################
# 函数：保存构建版本信息
##############################################################################

save_version_info() {
    echo "=== 保存版本信息 ==="
    
    cd "${OPENOCD_DIR}"
    
    local git_short_hash=$(git rev-parse --short HEAD)
    local git_full_hash=$(git rev-parse HEAD)
    local git_commit_date=$(git log -1 --format=%cd --date=short)
    
    # 创建版本信息文件
    cat > "${OUTPUT_DIR}/version_info.txt" << VERSION_INFO
# OpenOCD 构建版本信息
# 生成时间: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

OPENOCD_GIT_SHORT_HASH=${git_short_hash}
OPENOCD_GIT_FULL_HASH=${git_full_hash}
OPENOCD_BRANCH=master
OPENOCD_COMMIT_DATE=${git_commit_date}

BUILD_VERSION=${BUILD_VERSION}
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_PLATFORM=${PLATFORM}
BUILD_ARCH=${ARCH_NAME}
VERSION_INFO
    
    cd "${PWD}"
    
    echo "✓ 版本信息已保存到 ${OUTPUT_DIR}/version_info.txt"
    echo ""
}

##############################################################################
# 函数：打包构建产物
##############################################################################

package_build_artifacts() {
    echo "=== 打包构建产物 ==="
    
    # 创建打包目录
    mkdir -p "${PACKAGE_PATH}"
    
    # 根据平台复制文件
    if [ "${PLATFORM}" = "windows" ]; then
        package_windows_build
    else
        package_unix_build
    fi
    
    # 复制公共文件
    cp "${OUTPUT_DIR}/version_info.txt" "${PACKAGE_PATH}/"
    
    # 创建 README 文件
    create_readme_file
    
    # 压缩打包
    create_archive
    
    echo "✓ 打包完成"
    echo ""
}

##############################################################################
# 函数：打包 Unix 系统（Linux/macOS）构建产物
##############################################################################

package_unix_build() {
    # 复制 OpenOCD 可执行文件
    if [ -f "${BUILD_DIR}/bin/openocd" ]; then
        cp "${BUILD_DIR}/bin/openocd" "${PACKAGE_PATH}/"
        chmod +x "${PACKAGE_PATH}/openocd"
        echo "✓ 复制 openocd 可执行文件"
    elif [ -f "${OPENOCD_DIR}/src/openocd" ]; then
        cp "${OPENOCD_DIR}/src/openocd" "${PACKAGE_PATH}/"
        chmod +x "${PACKAGE_PATH}/openocd"
        echo "✓ 复制 openocd 可执行文件 (从源码目录)"
    fi
    
    # 复制配置脚本
    if [ -d "${BUILD_DIR}/share/openocd" ]; then
        cp -r "${BUILD_DIR}/share/openocd" "${PACKAGE_PATH}/"
        echo "✓ 复制 OpenOCD 配置文件"
    elif [ -d "${OPENOCD_DIR}/tcl" ]; then
        mkdir -p "${PACKAGE_PATH}/share/openocd"
        cp -r "${OPENOCD_DIR}/tcl" "${PACKAGE_PATH}/share/openocd/scripts"
        echo "✓ 复制 OpenOCD 配置文件 (从源码目录)"
    fi
}

##############################################################################
# 函数：打包 Windows 系统构建产物
##############################################################################

package_windows_build() {
    # 复制 OpenOCD 可执行文件
    if [ -f "${BUILD_DIR}/bin/openocd.exe" ]; then
        cp "${BUILD_DIR}/bin/openocd.exe" "${PACKAGE_PATH}/"
        echo "✓ 复制 openocd.exe 可执行文件"
    else
        cp "${OPENOCD_DIR}/src/openocd.exe" "${PACKAGE_PATH}/" 2>/dev/null || \
            cp "${OPENOCD_DIR}/src/openocd" "${PACKAGE_PATH}/"
        echo "✓ 复制 openocd 可执行文件 (从源码目录)"
    fi
    
    # 复制配置脚本
    if [ -d "${BUILD_DIR}/share/openocd" ]; then
        cp -r "${BUILD_DIR}/share/openocd" "${PACKAGE_PATH}/"
        echo "✓ 复制 OpenOCD 配置文件"
    elif [ -d "${OPENOCD_DIR}/tcl" ]; then
        mkdir -p "${PACKAGE_PATH}/share/openocd"
        cp -r "${OPENOCD_DIR}/tcl" "${PACKAGE_PATH}/share/openocd/scripts"
        echo "✓ 复制 OpenOCD 配置文件 (从源码目录)"
    fi
}

##############################################################################
# 函数：创建 README 文件
##############################################################################

create_readme_file() {
    cat > "${PACKAGE_PATH}/README.txt" << 'README'
=======================================================================
OpenOCD 二进制分发包
=======================================================================

本目录包含预编译的 OpenOCD 可执行文件及相关配置文件。

OpenOCD 是一个开源的片上调试器（On-Chip Debugger），支持多种
调试适配器和目标芯片。

目录结构：
  openocd[.exe]      - OpenOCD 主程序
  share/openocd/      - 配置文件和脚本目录

使用方法：
  1. 将此目录解压到任意位置
  2. 运行 openocd 可执行文件，配合适当的配置文件使用

基本示例：
  openocd -f interface/stlink.cfg -f target/stm32f1x.cfg

更多信息请访问：
  - OpenOCD 官方网站：https://openocd.org/
  - OpenOCD 文档：https://openocd.org/doc/html/
  - GitHub 仓库：https://github.com/openocd-org/openocd

许可证：
  OpenOCD 采用 GPLv2 许可证发布。
=======================================================================
README
    
    echo "✓ 创建 README.txt"
}

##############################################################################
# 函数：创建压缩归档文件
##############################################################################

create_archive() {
    cd "${OUTPUT_DIR}"
    
    if [ "${PLATFORM}" = "windows" ]; then
        local archive_file="${PACKAGE_NAME}.zip"
        echo "创建 ZIP 压缩包..."
        zip -r -q "${archive_file}" "${PACKAGE_NAME}"
    else
        local archive_file="${PACKAGE_NAME}.tar.gz"
        echo "创建 tar.gz 压缩包..."
        tar -czf "${archive_file}" "${PACKAGE_NAME}"
    fi
    
    # 计算 SHA256 校验和
    if command -v sha256sum &> /dev/null; then
        sha256sum "${archive_file}" > "${archive_file}.sha256"
        echo "✓ 计算 SHA256 校验和"
    elif command -v shasum &> /dev/null; then
        shasum -a 256 "${archive_file}" > "${archive_file}.sha256"
        echo "✓ 计算 SHA256 校验和"
    fi
    
    echo "✓ 压缩包已创建: ${archive_file}"
    
    cd "${PWD}"
}

##############################################################################
# 函数：验证构建产物
##############################################################################

validate_build_artifacts() {
    echo "=== 验证构建产物 ==="
    
    local validation_passed=true
    local openocd_executable=""
    
    # 确定可执行文件名
    if [ "${PLATFORM}" = "windows" ]; then
        openocd_executable="openocd.exe"
    else
        openocd_executable="openocd"
    fi
    
    # 检查 OpenOCD 可执行文件
    if [ -f "${PACKAGE_PATH}/${openocd_executable}" ]; then
        echo "✓ 找到 ${openocd_executable}"
        
        # 尝试执行版本检查（非 Windows 平台）
        if [ "${PLATFORM}" != "windows" ]; then
            if "${PACKAGE_PATH}/${openocd_executable}" --version &> /dev/null; then
                echo "✓ ${openocd_executable} 可正常执行"
            else
                echo "⚠ 警告：${openocd_executable} 执行失败（可能缺少运行时依赖）"
            fi
        fi
    else
        echo "✗ 错误：找不到 ${openocd_executable}"
        validation_passed=false
    fi
    
    # 检查配置文件目录
    if [ -d "${PACKAGE_PATH}/share/openocd/scripts" ] || [ -d "${PACKAGE_PATH}/share/openocd" ]; then
        echo "✓ 找到 OpenOCD 配置文件"
    else
        echo "⚠ 警告：未找到 OpenOCD 配置文件"
    fi
    
    # 检查版本信息文件
    if [ -f "${PACKAGE_PATH}/version_info.txt" ]; then
        echo "✓ 找到版本信息文件"
    else
        echo "⚠ 警告：未找到版本信息文件"
    fi
    
    echo ""
    if [ "${validation_passed}" = "true" ]; then
        echo "✓ 构建产物验证通过"
    else
        echo "✗ 构建产物验证失败"
        exit 1
    fi
    echo ""
}

##############################################################################
# 函数：打印构建完成信息
##############################################################################

print_build_summary() {
    echo "========================================="
    echo "  OpenOCD 构建完成！"
    echo "========================================="
    echo ""
    echo "构建产物位置："
    echo "  ${OUTPUT_DIR}/"
    echo ""
    echo "可用的文件："
    
    cd "${OUTPUT_DIR}"
    for file in *; do
        if [ -f "${file}" ]; then
            local file_size=$(du -h "${file}" | cut -f1)
            echo "  - ${file} (${file_size})"
        fi
    done
    cd "${PWD}"
    
    echo ""
    echo "========================================="
}

##############################################################################
# 主函数：执行完整的构建流程
##############################################################################

main() {
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║     OpenOCD 自动化构建脚本            ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    
    # 执行构建流程
    print_build_config
    create_directories
    check_build_environment
    install_platform_dependencies
    fetch_openocd_source
    build_openocd
    save_version_info
    package_build_artifacts
    validate_build_artifacts
    print_build_summary
}

##############################################################################
# 脚本入口
##############################################################################

# 运行主函数
main
